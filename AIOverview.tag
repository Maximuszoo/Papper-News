//Enter website URL
https://chat.deepseek.com/

//write in textarea
type //*[@id="root"]/div/div/div[2]/div[3]/div/div/div[2]/div[2]/div/div/div[1]/textarea as `prompt`

//click send button
click //*[@id="root"]/div/div/div[2]/div[3]/div/div/div[2]/div[2]/div/div/div[2]/div/div[2]

//wait for response to be generated (adjust time as needed)
wait 100

//extract the complete response from the specific location
read //*[@id="root"]/div/div/div[2]/div[3]/div/div[2]/div/div[2]/div[1]/div[2] to deepseek_response

//clean up the response and process JSON for WhatsApp
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
  
  // Try to extract JSON from the response
  var papers = [];
  try {
    // Look for JSON pattern in the response
    var jsonMatch = cleanResponse.match(/\{.*"papers".*\}/);
    if (jsonMatch) {
      var jsonData = JSON.parse(jsonMatch[0]);
      
      // Process each paper from the JSON
      if (jsonData.papers && Array.isArray(jsonData.papers)) {
        for (var i = 0; i < jsonData.papers.length; i++) {
          var paper = jsonData.papers[i];
          
          // Format the paper for WhatsApp
          var formattedPaper = '';
          if (paper.titulo_español) {
            formattedPaper += paper.titulo_español + '\n\n';
          }
          if (paper.resumen) {
            formattedPaper += paper.resumen + '\n\n';
          }
          if (paper.puntos_clave) {
            formattedPaper += paper.puntos_clave + '\n\n';
          }
          if (paper.enlace) {
            formattedPaper += paper.enlace;
          }
          
          // Add to papers array
          papers.push(formattedPaper.trim());
        }
      }
    }
  } catch (e) {
    // If JSON parsing fails, create an error message
    papers = ['Error al procesar la respuesta JSON: ' + e.message + '\n\nRespuesta original:\n' + cleanResponse];
  }
  
  // Fallback: if no papers found, add the original response
  if (papers.length === 0) {
    papers = ['No se encontraron papers en formato JSON.\n\nRespuesta original:\n' + cleanResponse];
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

// Open WhatsApp Web
https://web.whatsapp.com/

wait 7

// Click in the group chat name to open it
click Papper News 9129324123

for paper_index from 0 to total_papers-1
  js current_paper = paper_messages[paper_index]
  
  // Click the message input box, type the current paper, and send
  click //*[@id="main"]/footer/div[1]/div/span/div/div[2]/div/div[3]
  type //*[@id="main"]/footer/div[1]/div/span/div/div[2]/div/div[3] as `current_paper`
  click //*[@id="main"]/footer/div[1]/div/span/div/div[2]/div/div[4]/div/span/div/div/div[1]/div[1]

wait 5