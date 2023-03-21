*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Desktop
Library             OperatingSystem
Library             RPA.PDF
Library             RPA.Archive


*** Variables ***
${CSVFILE}=     orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the Excel File
    Give up all your constitutional rights
    Fill the form, order and Create PDF with Preview and Receipt
    Close Browser
    Create a ZIP File with the Receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the Excel File
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

Give up all your constitutional rights
    Set Local Variable    ${ok}    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[2]
    Wait And Click Button    ${ok}

Fill the form for one order
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    address    ${order}[Address]

Screenshot the Robot Preview and receipt and make a PDF from both
    [Arguments]    ${order}
    Click Button    preview
    Screenshot    robot-preview    ${OUTPUT_DIR}$/${order}[Order number]_preview.png
    Wait Until Keyword Succeeds    10x    5s    Click Button    order    #funktioniert nicht

    Wait Until Element Is Visible    id:receipt
    ${receips}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    $${receips}    ${OUTPUT_DIR}$/${order}[Order number]_receipt.pdf

    ${file}=    Create List    ${OUTPUT_DIR}$/${order}[Order number]_preview.png
    Add Files To Pdf
    ...    ${file}
    ...    ${OUTPUT_DIR}$/${order}[Order number]_receipt.pdf
    ...    append=${True}

Fill the form, order and Create PDF with Preview and Receipt
    ${orders}=    Read table from CSV    ${CURDIR}${/}${CSVFILE}

    FOR    ${order}    IN    @{orders}
        Fill the form for one order    ${order}
        Screenshot the Robot Preview and receipt and make a PDF from both    ${order}
        Click Button    order-another
        Give up all your constitutional rights
    END

Create a ZIP File with the Receipts
    Archive Folder With Zip    ${CURDIR}    receipts.Zip    recursive=${True}    include=*.pdf
