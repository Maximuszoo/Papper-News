//Create or overwrite CSV file with headers
write `csv_row(["name", "Description", "URL"])` to OUT/AutoPapper.csv

https://arxiv.org/

//Software engineering
click `xpath`

//Select new submissions and change to list view
click new

//Save in a variable the number of new submissions
read //*[@id="articles"]/h3 to submissions

echo `submissions`

// Extract number from string using JavaScript 
js begin
  var s = '' + submissions;
  var matches = s.match(/\d+/);
  if (matches) {
    number_value = parseInt(matches[0], 10);
  } else {
    number_value = 0;
  }
js finish

echo Number found is `number_value`

//wait 1000

// Create a loop to process each submission
for i from 1 to number_value

  // Get submission details
  click /html/body/div[3]/main/div/div/div/dl[1]/dt[`i`]/a[2]

  read //*[@id="abs"]/h1/text() to name

  read #abs blockquote to description

  fetch //a[@class="abs-button download-pdf"]/@href to direction

  url = "https://arxiv.org" + direction

  echo `name` - `description` - `url`

  // Navigate back to the list of submissions
  dom window.history.back()

  // Write submission details to CSV
  write `csv_row([name, description, url])` to OUT/AutoPapper.csv