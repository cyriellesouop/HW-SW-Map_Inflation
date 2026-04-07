import fitz  # PyMuPDF

input_path = "opcounts_512x512_k3_step500_twopanel.pdf"
output_path = "cropped_output.pdf"

# Open the PDF
doc = fitz.open(input_path)

# Select the first page (change index if needed)
page = doc[0]

# Get the full page rectangle
rect = page.rect

# Define crop margins (in points)
margin = 15  # adjust this value

# Create a new cropped rectangle
crop_rect = fitz.Rect(
    rect.x0 + margin,
    rect.y0 + margin,
    rect.x1 - margin,
    rect.y1 - margin
)

# Apply the crop
page.set_cropbox(crop_rect)

# Save the result
doc.save(output_path)

print("Cropped PDF saved as:", output_path)
