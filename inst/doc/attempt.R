## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  error = TRUE,
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
library(attempt)
attempt(log("a"))
# Error: argument non numérique pour une fonction mathématique

attempt(log("a"), msg = "Nop !")
# Error: Nop !

## ------------------------------------------------------------------------
attempt(log("a"), msg = "Nop !", verbose = TRUE)
# Error in log("a"): Nop !

## ------------------------------------------------------------------------
attempt(log(1), msg = "Nop !", verbose = TRUE)
# [1] 0

## ------------------------------------------------------------------------
a <- attempt(log("a"), msg = "Nop !", verbose = TRUE)
a
# [1] "Error in log(\"a\"): Nop !\n"
# attr(,"class")
# [1] "try-error"
# attr(,"condition")
# <simpleError in log("a"): Nop !>

## ------------------------------------------------------------------------
silent_attempt(log("a"))
# Error: argument non numérique pour une fonction mathématique
silent_attempt(log(1))

## ------------------------------------------------------------------------
try_catch(log("a"), 
          .e = ~ paste0("There is an error: ", .x), 
          .w = ~ paste0("This is a warning: ", .x))
#[1] "There is an error: Error in log(\"a\"): argument non numérique pour une fonction mathématique\n"

try_catch(log("a"), 
          .e = ~ stop(.x), 
          .w = ~ warning(.x))
# Error in log("a") : argument non numérique pour une fonction mathématique

try_catch(matrix(1:3, nrow= 2), 
          .e = ~ print(.x), 
          .w = ~ print(.x))
#<simpleWarning in matrix(1:3, nrow = 2): la longueur des données [3] n'est pas un diviseur ni un multiple du nombre de lignes [2]>

try_catch(2 + 2 , 
          .f = ~ print("Using R for addition... ok I'm out!"))
# [1] "Using R for addition... ok I'm out!"
# [1] 4

## ------------------------------------------------------------------------
try_catch(matrix(1:3, nrow = 2), .e = ~ print("error"))
#      [,1] [,2]
# [1,]    1    3
# [2,]    2    1
# Warning message:
# In matrix(1:3, nrow = 2) :
#   la longueur des données [3] n'est pas un diviseur ni un multiple du nombre de lignes [2]

## ------------------------------------------------------------------------
try_catch(matrix(1:3, nrow = 2), .w = ~ print("warning"))
# [1] "warning"

## ------------------------------------------------------------------------
try_catch(log("a"), 
          .e = function(e){
            print(paste0("There is an error: ", e))
            print("Ok, let's save this")
            time <- Sys.time()
            a <- paste("+ At",time, ", \nError:",e)
            # write(a, "log.txt", append = TRUE) # commented to prevent from log.txt creation on your machine
            print(paste("log saved on log.txt at", time))
            print("let's move on now")
          })

# [1] "There is an error: Error in log(\"a\"): argument non numérique pour une fonction mathématique\n"
# [1] "Ok, let's save this"
# [1] "log saved on log.txt at 2017-12-20 18:24:05"
# [1] "let's move on now"

## ------------------------------------------------------------------------
try_catch(log("a"), 
          .e = function(e){
            paste0("There is an error: ", e)
          },
          .f = ~ print("I'm not sure you can do that pal !"))
# [1] "I'm not sure you can do that pal !"
# [1] "There is an error: Error in log(\"a\"): argument non numérique pour une fonction mathématique\n"

## ----eval = TRUE---------------------------------------------------------
res_log <- try_catch_df(log("a"))
res_log
res_log$value

res_matrix <- try_catch_df(matrix(1:3, nrow = 2))
res_matrix
res_matrix$value

res_success <- try_catch_df(log(1))
res_success
res_success$value

## ----eval = TRUE---------------------------------------------------------
map_try_catch(l = list(1, 3, "a"), fun = log, .e = ~ .x)

map_try_catch_df(list(1,3,"a"), log)

## ----eval = TRUE---------------------------------------------------------
silent_log <- silently(log)
silent_log(1)
silent_log("a")
# Error: argument non numérique pour une fonction mathématique

## ------------------------------------------------------------------------
silent_matrix <- silently(matrix)
silent_matrix(1:3, 2)
# simpleWarning: la longueur des données [3] n'est pas un diviseur ni un multiple du nombre de lignes [2]

## ------------------------------------------------------------------------
sure_log <- surely(log)
sure_log(1)
# [1] 0
sure_log("a")
# Error: argument non numérique pour une fonction mathématique

## ----eval=TRUE-----------------------------------------------------------
if_all(1:10, ~ .x < 11, ~ return(letters[1:10]))

if_any(1:10, is.numeric, ~ print("Yay!"))

if_none(1:10, is.character, ~ rnorm(10))

## ----eval=TRUE-----------------------------------------------------------
a <- c(FALSE, TRUE, TRUE, TRUE)

if_any(a, .f = ~ print("nop!"))

## ----eval=TRUE-----------------------------------------------------------
if_then(1, is.numeric, ~ return("nop!"))

## ----eval=TRUE-----------------------------------------------------------
a <- if_else(1, is.numeric, ~ return("Yay"), ~ return("Nay"))
a

## ------------------------------------------------------------------------
x <- 12
# Stop if .x is numeric
stop_if(.x = x, 
        .p = is.numeric)

y <- "20"
# stop if .x is not numeric
stop_if_not(.x = y, 
            .p = is.numeric, 
            msg = "y should be numeric")
a  <- "this is not numeric"
# Warn if .x is charcter
warn_if(.x = a, 
        .p = is.character)

b  <- 20
# Warn if .x is not equal to 10
warn_if_not(.x = b, 
        .p = ~ .x == 10 , 
        msg = "b should be 10")

c <- "a"
# Message if c is a character
message_if(.x = c, 
           .p = is.character, 
           msg = "You entered a character element")

# Build more complex predicates
d <- 100
message_if(.x = d, 
           .p = ~ sqrt(.x) < 42, 
           msg = "The square root of your element must be more than 42")

# Or, if you're kind of old school, you can still pass classic functions

e <- 30
message_if(.x = e, 
           .p = function(vec){
             return(sqrt(vec) < 42)
           }, 
           msg = "The square root of your element must be more than 42")

## ------------------------------------------------------------------------
true <- function() TRUE
false <- function() FALSE
stop_if(., true, msg = "You shouldn't have internet to do that")

warn_if(., false, 
            msg = "You shouldn't have internet to do that")

message_if(., true, 
            msg = "Huray, you have internet \\o/")

## ------------------------------------------------------------------------
a <- is.na(airquality$Ozone)
message_if_any(a, msg = "NA found")

## ------------------------------------------------------------------------
my_fun <- function(x){
  stop_if_not(., 
              false, 
              msg = "You should have internet to do that")
  warn_if(x, 
          ~ ! is.character(.x), 
          msg =  "x is not a character vector. The output may not be what you're expecting.")
  paste(x, "is the value.")
}

my_fun(head(iris))

## ------------------------------------------------------------------------
stop_if_any(iris, is.factor, msg = "Factors here. This might be due to stringsAsFactors.")

warn_if_none(1:10, ~ .x < 0, msg = "You need to have at least one number under zero.")

message_if_all(1:100, is.numeric, msg = "That makes a lot of numbers.")

