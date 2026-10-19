# ==============================================================================
# PROYECTO 1: GESTIÓN DE RIESGO DE MERCADO Y VaR
# Script 01: Ingesta de Datos Financieros y Retornos Logarítmicos
# ==============================================================================

# 1. Cargar gestor de librerías
if (!require("pacman")) install.packages("pacman")
pacman::p_load(quantmod, tidyverse, lubridate)

# 2. Definir Activos Financieros y Rango de Fechas
tickers <- c("AAPL", "JPM", "SPY", "GLD")
fecha_inicio <- Sys.Date() - years(5)
fecha_fin    <- Sys.Date()

cat("Descargando datos desde Yahoo Finance usando quantmod...\n")

# 3. Descarga Robusta con quantmod
datos_lista <- list()

for (ticker in tickers) {
  tryCatch({
    # Descargar serie xts
    datos_env <- new.env()
    getSymbols(ticker, src = "yahoo", from = fecha_inicio, to = fecha_fin, env = datos_env, auto.assign = TRUE)
    
    xts_data <- datos_env[[ticker]]
    
    # Convertir a tibble limpio
    df_ticker <- data.frame(
      date = index(xts_data),
      symbol = ticker,
      adjusted = as.numeric(Ad(xts_data))
    )
    
    datos_lista[[ticker]] <- df_ticker
    cat("  -> Descargado con éxito:", ticker, "\n")
  }, error = function(e) {
    warning(paste("No se pudo descargar", ticker, ":", e$message))
  })
}

# Unir todos los datos en un único DataFrame
precios_raw <- bind_rows(datos_lista)

# Validar que los datos existan
if (nrow(precios_raw) == 0) {
  stop("Error: No se pudieron obtener datos. Verifica tu conexión.")
}

# 4. Transformación: Retornos Logarítmicos
datos_procesados <- precios_raw %>%
  group_by(symbol) %>%
  arrange(date) %>%
  mutate(
    retorno_log = log(adjusted / lag(adjusted))
  ) %>%
  drop_na(retorno_log) %>%
  select(date, symbol, adjusted, retorno_log)

# 5. Guardar Dataset en la carpeta data/
write_csv(datos_procesados, "data/retornos_portafolio.csv")
cat("\n¡Éxito total! Archivo guardado en data/retornos_portafolio.csv\n")