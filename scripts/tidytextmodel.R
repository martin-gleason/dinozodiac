#idytext and modeling
library(tidyverse)
library(DBI)
library(odbc)
library(tidytext)
library(keras)
library(here)
library(tokenizers)
library(tensorflow)
reticulate::py_config()
tensorflow::tf_config()


#install_keras(method = "conda")
dz <- config::get(file = 'connections/dinozodiac.yml')

con <- DBI::dbConnect(odbc::odbc(),
                      Driver = dz$dinozodiac$driver,
                      Servere = dz$dinozodiac$server,
                      UID = dz$dinozodiac$uid,
                      PWD = dz$dinozodiac$pwd,
                      Port = dz$dinozodiac$port,
                      Database = dz$dinozodiac$database
)

max_length <- 44

scopes_text <- dbReadTable(con, "scopes") %>%
  select(scope) %>%
  pull() %>%
  str_c(collapse = " ") %>%
  tokenize_characters(lowercase = FALSE,
                      strip_non_alphanum = FALSE,
                      simplify = TRUE)
  


chars <- scopes_text %>%
  unique() %>%
  sort()

dinoset <- map(
  seq(1, length(scopes_text) - max_length -1, by = 3),
  ~list(sentence = scopes_text[.x:(.x + max_length - 1)],
        next_char = scopes_text[.x + max_length])
)

dinoset <- transpose(dinoset)

vectorize <- function(data, chars, max_length){
  x <- array(0, dim = c(length(data$sentence), 
                        max_length, length(chars)))
  y <- array(0, dim = c(length(data$sentence), length(chars)))

  for(i in 1:length(data$sentence)){
    x[i,,] <- sapply(chars, function(x){
      as.integer((x == data$sentence[[i]]))
    })
    y[i,] <- as.integer(chars == data$next_char[[i]])
  }
  
  list(y = y,
       x = x)
  }

vectors <- vectorize(dinoset, chars, max_length)

#MODEL
create_model <- function(chars, max_length){
  keras_model_sequential() %>%
    layer_lstm(128, input_shape = c(max_length, length(chars))) %>%
    layer_dense(length(chars)) %>%
    layer_activation("softmax") %>%
    compile(
        loss = "categorical_crossentropy",
        optimizer = optimizer_rmsprop(lr = 0.01)
    )
}

fit_model <- function(model, vectors, epochs = 1){
  model %>% fit(
    vectors$x, vectors$y,
    batch_size = 128,
    epochs = epochs
  )
  NULL
}

generate_phrase <- function(model, text, chars, max_length, diversity){
  #Character gent
  choose_next_char <- function(preds, chars, temperature){
    preds <- log(preds) / temperature
    exp_preds <- exp(preds)
    preds <- exp_preds / sum(exp(preds))
    
    next_index <- rmultinom(1, 1, preds) %>%
      as.integer() %>%
      which.max
    
    chars[next_index]
  }
  
  #numeric array
  
  sentence_to_data <- function(sentence, chars){
    x <- sapply(chars, function(x){
      as.integer(x == sentence)
      })
    array_reshape(x, c(1, dim(x)))
  }
  
  #initial
  
  start_index <- sample(1:(length(text) - max_length), size =1)
  sentence <- text[start_index:(start_index + max_length - 1)]
  generated <- ""
  
  #forloop to make more characters?
  for(i in 1:(max_length*20)){
    
    sentence_data <- sentence_to_data(sentence, chars)
    
    preds <- predict(model, sentence_data)
    
    next_char <- choose_next_char(preds, chars, diversity)
    
    generated <- str_c(generated, next_char, collapse = "")
    sentence <- c(sentence[-1], next_char)
  }
  
  generated
}


iterate_model <- function(model, text, chars, max_length, diversity, vectors, iterations){
  for(iteration in 1:iterations){
    message(sprintf("iteration: %02d ---------------\n\n", iteration))
    
    fit_model(model, vectors)

    
    for(diversity in c(0.2, 0.5, 1)){
      message(sprintf("diversity: %f ---------------\n\n", diversity))
      
      current_phrase <- 1:10 %>%
        map_chr(function(x) generate_phrase(model, text, chars, max_length, diversity))
      
      message(current_phrase, sep = "\n")
      message("\n\n")
      
    }
  }
  NULL
}


model <- create_model(chars, max_length)
iterate_model(model, scopes_text, chars, max_length, diversity, vectors, 40)