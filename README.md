Convert R scripts to Quarto scripts.

Isn't there a simple way? I have not found any similar script and generative AI websites like ChatGPT or Copilot struggle to return Quarto code as they use backtick symbol (`) to denote its own code block (https://www.reddit.com/r/OpenAI/comments/103xt7u/how_can_i_ask_chatgbt_to_output_answers_in_raw/). I haven't found a way to change this.

# Set up
Works with the R script format used in the template https://github.com/jamonterotena/Rscript-template.

This format contains a header with script metadata and code sections (#### SECTION NAME ####). Code sections enables collapsing and expanding pieces of code in RStudio, which I find very practical with long code.

The idea is that the Code sections mark the location of the Quarto chunks. The section names will appear as titles (# ) in the Quarto file.
