*** Settings ***
Library                   QWeb
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Keywords ***
Setup Browser
    Open Browser          about:blank    chrome
    SetConfig             DefaultTimeout    20s
    SetConfig             LineBreak         ${EMPTY}

End Suite
    Close All Browsers

*** Test Cases ***
Verify Gerald The Giraffe T-Shirt Price And Add To Cart
    [Documentation]       Navigates to the webshop, verifies price of Gerald the Giraffe
    ...                   T-shirt is $9.00, adds it to cart, and verifies cart total is $9.00.
    [Tags]                Assignment1    WebShop

    # Step 1: Navigate to the webshop
    GoTo                  https://qentinelqi.github.io/shop/

    # Step 2: Verify Gerald the Giraffe is listed with price $9.00
    VerifyText            Gerald the Giraffe
    VerifyText            $9.00                anchor=Gerald the Giraffe

    # Step 3: Navigate to the Gerald the Giraffe product page and verify price
    ClickText             Gerald the Giraffe
    VerifyText            $9.00

    # Step 4: Add to cart
    ClickText             Add to cart

    # Step 5: Open shopping cart and verify total is $9.00
    ClickText             shopping_cart
    VerifyText            $9.00                anchor=Total
