//Enter website URL
https://chat.deepseek.com/

//write in textarea
type //*[@id="root"]/div/div/div[2]/div[3]/div/div/div[2]/div[2]/div/div/div[1]/textarea as `prompt`

//click send button
click //*[@id="root"]/div/div/div[2]/div[3]/div/div/div[2]/div[2]/div/div/div[2]/div/div[2]

//wait for response to be generated (adjust time as needed)
wait 90

//extract the complete response from the specific location
read //*[@id="root"]/div/div/div[2]/div[3]/div/div[2]/div/div[2]/div[1]/div[2] to deepseek_response

//clean up the response and make it beautiful for WhatsApp
js begin
  // Remove HTML tags and convert to plain text
  var cleanResponse = deepseek_response.replace(/<[^>]*>/g, '');
  
  // Replace HTML entities
  cleanResponse = cleanResponse.replace(/&nbsp;/g, ' ');
  cleanResponse = cleanResponse.replace(/&amp;/g, '&');
  cleanResponse = cleanResponse.replace(/&lt;/g, '<');
  cleanResponse = cleanResponse.replace(/&gt;/g, '>');
  cleanResponse = cleanResponse.replace(/&quot;/g, '"');
  
  // Clean up extra whitespace and normalize spaces
  cleanResponse = cleanResponse.replace(/\s+/g, ' ').trim();
  
  // Replace ** bold markers with WhatsApp formatting
  cleanResponse = cleanResponse.replace(/\*\*(.*?)\*\*/g, '*$1*');
  
  // Split by HR tags (papers are separated by <hr> in the original HTML)
  // Since we removed HTML tags, we need to split by a marker
  // First, let's identify paper boundaries by looking for emoji patterns
  var papers = [];
  var paperSections = cleanResponse.split(/(?=🔬\s*\*?Título en Español)/);
  
  // Process each paper section
  for (var i = 0; i < paperSections.length; i++) {
    var paper = paperSections[i].trim();
    
    // Skip empty sections
    if (!paper || paper.length < 10) continue;
    
    // Clean up the paper content
    paper = paper.replace(/\s+/g, ' ').trim();
    
    // Add proper line breaks for WhatsApp formatting
    paper = paper.replace(/🔬\s*/g, '\n🔬 ');
    paper = paper.replace(/📝\s*/g, '\n📝 ');
    paper = paper.replace(/🎯\s*/g, '\n🎯 ');
    paper = paper.replace(/🔗\s*/g, '\n🔗 ');
    
    // Remove leading newlines
    paper = paper.replace(/^\n+/, '');
    
    // Add to papers array
    papers.push(paper);
  }
  
  // Store papers array and total count for the for loop
  paper_messages = papers;
  total_papers = papers.length;
  
  // For debugging - show first paper as whatsapp_content
  whatsapp_content = papers.length > 0 ? papers[0] : 'No papers found';
js finish

echo ============================================================================
echo `whatsapp_content`
echo ============================================================================
echo Total papers encontrados: `total_papers`

https://web.whatsapp.com/

wait 7

click Papper News 9129324123

for paper_index from 0 to total_papers-1
  js current_paper = paper_messages[paper_index]
  
  click //*[@id="main"]/footer/div[1]/div/span/div/div[2]/div/div[3]
  type //*[@id="main"]/footer/div[1]/div/span/div/div[2]/div/div[3] as `current_paper`
  click //*[@id="main"]/footer/div[1]/div/span/div/div[2]/div/div[4]/div/span/div/div/div[1]/div[1]

wait 5