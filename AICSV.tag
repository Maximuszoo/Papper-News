//Create or overwrite CSV file with headers
write `csv_row(["titulo", "resumen", "puntos_clave", "enlace", "fecha_procesado"])` to OUT/ProcessedPapers.csv

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

//clean up the response and process JSON for CSV
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
  
  // Debug: show cleaned response
  debug_response = cleanResponse.substring(0, 500) + '...'; // First 500 chars
  
  // Try to extract JSON from the response
  var papers = [];
  jsonData = null; // Make it global for later use
  debug_error = ''; // Initialize debug_error
  
  try {
    // Look for JSON pattern in the response
    var jsonMatch = cleanResponse.match(/\{.*"papers".*\}/);
    if (jsonMatch) {
      debug_json_found = 'JSON encontrado: ' + jsonMatch[0].substring(0, 200) + '...';
      jsonData = JSON.parse(jsonMatch[0]);
      
      // Process each paper from the JSON
      if (jsonData.papers && Array.isArray(jsonData.papers)) {
        papers_count = jsonData.papers.length;
        debug_papers_array = 'Array de papers encontrado con ' + papers_count + ' elementos';
        
        for (var i = 0; i < jsonData.papers.length; i++) {
          var paper = jsonData.papers[i];
          papers.push('Paper ' + (i+1) + ': ' + (paper.titulo_español || 'Sin título'));
        }
      } else {
        debug_papers_array = 'No se encontró array de papers en JSON';
        papers_count = 0;
      }
    } else {
      debug_json_found = 'No se encontró patrón JSON en la respuesta';
      papers_count = 0;
    }
  } catch (e) {
    debug_error = 'Error al procesar JSON: ' + e.message;
    papers_count = 0;
  }
  
  // Store for debugging
  total_papers = papers_count || 0;
js finish

echo ============================================================================
echo DEBUG - Respuesta limpia (primeros 500 chars): `debug_response`
echo ============================================================================
echo DEBUG - JSON: `debug_json_found`
echo ============================================================================
echo DEBUG - Papers array: `debug_papers_array`
echo ============================================================================

if debug_error not equals to ''
  echo DEBUG - Error: `debug_error`
  echo ============================================================================

echo Total papers encontrados: `total_papers`
echo ============================================================================

// Write each paper to CSV if we have valid data
if total_papers greater than 0
  for csv_index from 0 to total_papers-1
    js begin
      if (jsonData && jsonData.papers && jsonData.papers[csv_index]) {
        var paper = jsonData.papers[csv_index];
        csv_titulo = (paper.titulo_español || '').replace(/"/g, '""');
        csv_resumen = (paper.resumen || '').replace(/"/g, '""');
        csv_puntos = (paper.puntos_clave || '').replace(/"/g, '""');
        csv_enlace = (paper.enlace || '').replace(/"/g, '""');
        csv_fecha = new Date().toISOString().split('T')[0];
        
        debug_saving = 'Guardando paper ' + (csv_index + 1) + ': ' + csv_titulo.substring(0, 50) + '...';
      } else {
        debug_saving = 'Error: No se pudo acceder al paper ' + csv_index;
        csv_titulo = csv_resumen = csv_puntos = csv_enlace = csv_fecha = '';
      }
    js finish
    
    echo Guardando: `debug_saving`
    write `csv_row([csv_titulo, csv_resumen, csv_puntos, csv_enlace, csv_fecha])` to OUT/ProcessedPapers.csv

echo ============================================================================
echo Proceso completado.
echo ============================================================================
