# ==============================================================================
# PROYECTO 1: GESTIÓN DE RIESGO DE MERCADO Y VaR
# Script 02: Modelado GARCH(1,1) y Cálculo del Value at Risk (VaR 95% y 99%)
# ==============================================================================

# 1. Cargar librerías cuantitativas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rugarch, PerformanceAnalytics)

# 2. Cargar datos procesados
datos <- read_csv("data/retornos_portafolio.csv")

# 3. Función para estimar GARCH(1,1) y extraer VaR dinámico
calcular_var_garch <- function(symbol_target, df) {
  
  retornos_vector <- df %>% 
    filter(symbol == symbol_target) %>% 
    pull(retorno_log)
  
  fechas_vector <- df %>% 
    filter(symbol == symbol_target) %>% 
    pull(date)
  
  # Especificación del Modelo GARCH(1,1) con distribución Student-t (colas pesadas)
  spec <- ugarchspec(
    variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
    mean.model     = list(armaOrder = c(0, 0), include.mean = TRUE),
    distribution.model = "std"
  )
  
  # Ajuste del modelo
  fit <- ugarchfit(spec = spec, data = retornos_vector)
  
  # Extraer volatilidad condicional estimada (sigma) y media
  sigma_t <- as.numeric(sigma(fit))
  mu_t    <- as.numeric(fitted(fit))
  
  # Extraer parámetro shape (grados de libertad) de forma directa
  shape_param <- fit@fit$coef["shape"]
  
  # Calcular VaR al 95% y 99% (percentil t-Student condicional)
  q_95 <- qdist("std", p = 0.05, mu = 0, sigma = 1, shape = shape_param)
  q_99 <- qdist("std", p = 0.01, mu = 0, sigma = 1, shape = shape_param)
  
  var_95 <- -(mu_t + sigma_t * q_95)
  var_99 <- -(mu_t + sigma_t * q_99)
  
  tibble(
    date = fechas_vector,
    symbol = symbol_target,
    retorno_log = retornos_vector,
    volatilidad_garch = sigma_t,
    var_95 = var_95,
    var_99 = var_99
  )
}

# 4. Aplicar el modelo a cada activo del portafolio
cat("Estimando modelos GARCH(1,1) para cada activo...\n")
activos <- unique(datos$symbol)
resultados_var <- map_df(activos, ~calcular_var_garch(.x, datos))

# 5. Guardar el archivo final para Power BI
write_csv(resultados_var, "data/var_garch_resultados.csv")
cat("\n¡Éxito total! Archivo generado en data/var_garch_resultados.csv\n")