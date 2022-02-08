import pdf2image as img
import pytesseract as tess
import PyPDF2 as Pdf
from PIL import Image

from pdfseparator import pdfseparator

tess.pytesseract.tesseract_cmd = r'C:\Users\George\AppData\Local\Tesseract-OCR\tesseract.exe'


# even index col1 20,60 197,770
# even index col2 192,40 370,770
# even index col3 362,60 560,770

# odd index col1 40,15 223,773
# odd index col2 219,15 408,773
# odd index col3 403,15 590,773



def readindex(numpdf, pdfFolderName, outputfilename):
    for k in range(numpdf):
        # pdf name
        pdfname = pdfFolderName + "/" + "Index-Chunk%s" % k + ".pdf"
        pdf = Pdf.PdfFileReader(pdfname)

        text_file = open(outputfilename, "a")

        # Loop through the pdf chunks
        for i in range(pdf.getNumPages()):

            # odd index page
            if i % 2 == 1:
                # col1
                pdf = Pdf.PdfFileReader(pdfname)
                page1 = pdf.getPage(i)
                page1.mediaBox.setLowerLeft((0, 15))
                page1.mediaBox.setUpperRight((217, 770))
                writer = Pdf.PdfFileWriter()
                writer.addPage(page1)


                # col2
                pdf = Pdf.PdfFileReader(pdfname)
                page2 = pdf.getPage(i)
                page2.mediaBox.setLowerLeft((213, 15))
                page2.mediaBox.setUpperRight((388, 770))
                writer.addPage(page2)


                # col3
                pdf = Pdf.PdfFileReader(pdfname)
                page3 = pdf.getPage(i)
                page3.mediaBox.setLowerLeft((384, 15))
                page3.mediaBox.setUpperRight((600, 770))
                writer.addPage(page3)


            # even index page
            if i % 2 == 0:
                # col1
                pdf = Pdf.PdfFileReader(pdfname)
                page1 = pdf.getPage(i)
                page1.mediaBox.setLowerLeft((0, 15))
                page1.mediaBox.setUpperRight((200, 773))


                writer = Pdf.PdfFileWriter()
                writer.addPage(page1)
                # col2
                pdf = Pdf.PdfFileReader(pdfname)
                page2 = pdf.getPage(i)
                page2.mediaBox.setLowerLeft((187, 15))
                page2.mediaBox.setUpperRight((373, 773))
                writer.addPage(page2)

                # col3
                pdf = Pdf.PdfFileReader(pdfname)
                page3 = pdf.getPage(i)
                page3.mediaBox.setLowerLeft((359, 15))
                page3.mediaBox.setUpperRight((580, 773))
                writer.addPage(page3)

            # convert pdf to png then png to text

            outstream = open('cols.pdf', 'wb')
            writer.write(outstream)
            outstream.close()

            Img = img.convert_from_path('cols.pdf')

            # ../pics/
            Img[0].save("col1.png")
            Img[1].save("col2.png")
            Img[2].save("col3.png")

            col1img = Image.open('col1.png')
            col2img = Image.open('col2.png')
            col3img = Image.open('col3.png')

            text1 = tess.image_to_string(col1img)
            text2 = tess.image_to_string(col2img)
            text3 = tess.image_to_string(col3img)
            text = text1 + text2 + text3

            text_file.write(text)

    text_file.close()


numpdf = pdfseparator(10, 360, 50, "Output", "Index-1953.pdf")

readindex(numpdf, "Output", "Index_HALF")
