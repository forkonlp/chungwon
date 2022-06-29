# body data
#

url <- "http://19president.pa.go.kr/petitions/605239"

hobj <- rvest::read_html(url)

hobj |>
  rvest::html_nodes("h3.petitionsView_title") |>
  rvest::html_text() -> title

hobj |>
  rvest::html_nodes("span.counter") |>
  rvest::html_text() |>
  stringr::str_replace_all(",","") |>
  as.integer() -> count

hobj |>
  rvest::html_nodes("ul.petitionsView_info_list li") |>
  purrr::map_chr(
    ~ as.character(.x) |>
      stringr::str_remove_all("<p>.*</p>") |>
      rvest::read_html() |>
      rvest::html_text() |>
      trimws()
  ) -> meta

meta[1] -> category
meta[2] -> startDate
meta[3] -> endDate

hobj |>
  rvest::html_nodes("div.View_write") |>
  as.character() |>
  stringr::str_split("<br>") -> spl

spl[[1]] |>
  stringr::str_remove_all("<div.*>") |>
  stringr::str_remove_all("</div>") |>
  purrr::map_chr(~trimws(.x)) |>
  tibble::as_tibble() |>
  dplyr::filter(stringr::str_length(value) != 0) -> body


hobj |>
  rvest::html_nodes(".View_write_link a") |>
  rvest::html_attr("href") -> contain_links


# list data
#
url  <- "http://19president.pa.go.kr/api/petitions/list"
bo <- list(
  c = 0, # 0 = 모두
  only = 2, # 1 = 진행중 청원 / 2 = 만료된 청원
  page = 1,
  order = 1 # 1 = 최신순 / 2 = 추천순
)
ah <- httr::add_headers(
  "X-Requested-With" =  "XMLHttpRequest"
  )

httr::POST(url, body = bo, ah) |>
  httr::content() -> tem
