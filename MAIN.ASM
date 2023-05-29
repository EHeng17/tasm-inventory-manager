.model small
.stack 100h
.data

        ; Initial Values of Stock
        tableStock dw 16
        chairStock dw 3
        cupboardStock dw 117

        ; Prices of Stock
        tablePrice dw 20
        chairPrice dw 15
        cupboardPrice dw 40

        ; Sales
        cart db 3 dup(0) ; Cart For User
        total dw 0
        totalSales dw 0

        ; User's username
        askUsername db 10,10 ,'Enter Your Name: $'
        greetingMessage db 13,10,10,'Welcome $'
        buffer db 100 dup(0)

        mainMenu db 10,10,10, "------------------------"
                db 10, "--- Inventory System ---" ; 10 is newline
                db 10, "------------------------"
                db 10, " 1. Purchase Furniture"
                db 10, " 2. Total Sales"
                db 10, " 3. Manage Inventory"
                db 10, " 4. Cart"
                db 10, " 5. Exit"
                db 10, "------------------------"
                db 10, "Please Select Your Choice: $"
        
        invalidInput db 10, 10, "------------------ Error -------------------"
                db 10, "Invalid input. Please enter a proper number!!!"
                db 10, "--------------------------------------------$"

        purchaseItemMenu db 10,10,10, "-----------------------------"
                db 10, "----- List of Furniture -----"
                db 10, "-----------------------------"
                db 10, "1. Table     = RM 20"
                db 10, "2. Chair     = RM 15"
                db 10, "3. Cupboard  = RM 40"
                db 10, "4. Back"
                db 10, "-------------------------"
                db 10, "Which item would you like to purchase?: $"

        purchaseItemInput db 10, "How many would you like to purchase?: $"

        addedToCartMessage db 10, 10, "Items Added to Cart!!!"
                db 10, "You can view your cart in the cart page.$" 
        
        purchaseExceed db 10, 10, "Sorry, your purchase amount exceed the current stock we have."
                db 10, "Input a lower number !!!$"

        addToCartQuestion db 10, 10, "Would you like to buy anything else?"
                db 10, "1. Yes"
                db 10, "2. No"
                db 10, "Enter your input: $"

        totalSalesHeader db 10,10,10,"Total Sales: RM$"

        manageInventoryHeader db 10,10,10,"-------------------------"
                db 10, "------- Inventory -------"
                db 10, "-------------------------"
                db 10
                db 10, "Stock: "
                db 10, "Table    =  $"

        chairString db 10, "Chair    =  $"
        cupboardString db 10, "Cupboard =  $"

        manageInventoryMenu db 10,10,"1. Add Stock"
                db 10, "2. Back"
                db 10, "Enter your input: $"

        addStockMenu db 10,10,10,"-------------------------"
                db 10, "------- Add Stock -------"
                db 10, "-------------------------"
                db 10
                db 10, "1. Table"
                db 10, "2. Chair"
                db 10, "3. Cupboard"
                db 10, 10, "Input a number to add the stock: $"

        addInput db 10, "Enter the number to add: $"

        cartInterfaceMenu db 10,10,10, "----------------"
                db 10, "----- Cart -----"
                db 10, "----------------"
                db 10
                db 10, "Table    =  $"

        cartOptions db 10,10, "1. Checkout"
                db 10, "2. Back"
                db 10, "Enter your input: $"

        cartTotal db 10, 10, "Total(RM) = $"
        checkoutSuccessMessage db 10, 10, "Furniture purchased successfully !!!$"
        cartEmptyValidationMessage db 10, 10, "Cart Is Empty!!!"
                db 10, "Checkout Failed. $"
                

.code

purchaseItemProc proc

purchaseItemMacro Macro stock, price, cartIndex

        ; Display Message
        mov ah, 09h
        mov dx, offset purchaseItemInput
        int 21h

        ; Character Input (Quantity of Item)
        mov ah, 01h
        int 21h
        sub al, 30h

        mov bx, offset stock ; Load Stock

        ; Making Sure amount purchased it can't exceed the current stock number
        cmp [bx], al
        jl unableToPurchase

        sub [bx], al ; Subtract Quantity From Stock

        add cartIndex, al ; Add quantity inputted by user to cart

        ; Multiply character input by tablePrice
        mov bl, al
        mov ax, [price] ; load tablePrice to AX
        mul bl ; multiply AX and BL, result in AX

        mov bx, offset total 
        add [bx], ax

        jmp addToCart                     

endm

printPurchaseItemHeader:
        ; Display Message
        mov ah, 09h
        mov dx, offset purchaseItemMenu
        int 21h

        ; Character Input
        mov ah, 01h
        int 21h       

        ; Conditions
        cmp al, '1' ; If user wants to purchase table
        je purchaseTable

        cmp al, '2' ; If user wants to purchase chair
        je purchaseChair

        cmp al, '3' ; If user wants to purchase cupboard
        je purchaseCupboard

        cmp al, '4' ; Go back to Main Menu
        je return

        ; If input is not 1 to 3
        jmp purchaseItemInvalidInput

return:
        ret

addToCart:
        ; Display Message
        mov ah, 09h 
        mov dx, offset addToCartQuestion
        int 21h

        ; Character Input (Quantity of Item)
        mov ah, 01h
        int 21h

        cmp al, '1' ; If user still wants to add more furniture into cart
        je printPurchaseItemHeader

        jmp addEverything

purchaseTable:

        purchaseItemMacro tableStock, tablePrice, cart[0]

purchaseChair:

        purchaseItemMacro chairStock, chairPrice, cart[1]

purchaseCupboard:

        purchaseItemMacro cupboardStock, cupboardPrice, cart[2]

addEverything: 

        ; Display Message
        mov ah, 09h
        mov dx, offset addedToCartMessage
        int 21h    

        jmp return  

unableToPurchase:
        ; Display Message
        mov ah, 09h 
        mov dx, offset purchaseExceed
        int 21h

        jmp printPurchaseItemHeader

purchaseItemInvalidInput:
        ; Display Message
        mov ah, 09h 
        mov dx, offset invalidInput
        int 21h    

        jmp printPurchaseItemHeader    



purchaseItemProc endp

addStock proc

addStockMacro Macro stock

        ; Display Message
        mov ah, 09h
        mov dx, offset addInput
        int 21h

        ; Character Input
        mov ah, 01h
        int 21h
        sub al, 30h

        mov bx, offset stock
        add [bx], al     ; add user input with stock                           

endm

printAddStockHeader:
        ; Display Message
        mov ah, 09h
        mov dx, offset addStockMenu
        int 21h

        ; Character Input
        mov ah, 01h
        int 21h

        ; Conditions
        cmp al, '1' ; If user wants to add table
        je addTable

        cmp al, '2' ; If user wants to add chair
        je addChair

        cmp al, '3' ; If user wants to add cupboard
        je addCupboard

        jmp addStockInvalidInput

addTable:

        addStockMacro tableStock
        jmp addStockReturn

addChair:

        addStockMacro chairStock
        jmp addStockReturn

addCupboard:

        addStockMacro cupboardStock
        jmp addStockReturn

addStockInvalidInput:
        ; Display Message
        mov ah, 09h
        mov dx, offset invalidInput
        int 21h

        jmp printAddStockHeader

addStockReturn:
        ret

addStock endp

displayInteger proc

        ; If stock less than 5, use lowStock (Which is BIOS)
        cmp ax, 5       
        jle lowStock

        ; To determine how many times to loop after constantly dividing by 10
        mov cx, 0         
        mov bx, 10        ; Used for dividing by 10 later

convertToString:
        ; Divide 10 with AX (Remainder will be in dx)
        mov dx, 0     
        div bx       
        
        push ax      ; Save the quotient in the stack
        add dl, '0'  ; Convert the remainder to a character

        pop ax       ; Restore the quotient from the stack
        push dx      ; Push the converted remainder onto the stack
        inc cx       ; Increment the counter (used for printing later)
        cmp ax, 0    ; Compare the quotient to 0
        jnz convertToString ; If the quotient is not 0, loop again

        mov ah, 02h

displayString:
        pop dx    ; Pop the top character from the stack into register DX
        int 21h   ; Display
        dec cx    ; Decrement the counter
        jnz displayString ; If there are still characters to print, loop again

        ret

lowStock:
        mov ah, 09h
        add ax, '0'
        mov bh, 0
        mov bl, 4Fh ; Red background
        mov cx, 1 ; Since lesser than 5 will only be highlighted, it will always be 1 character
        int 10h
        ret        

displayInteger endp

checkoutProc proc

printCartMacro Macro cartIndex
        ; Display Stock Amount in Cart
        mov ah, 02h
        mov al, cartIndex
        add al, '0' ; convert ASCII code
        mov dl, al
        int 21h        

endm

printCart:
        ; Display Message
        mov ah, 09h
        mov dx, offset cartInterfaceMenu
        int 21h

        printCartMacro cart[0]

        ; Display Chair String
        mov ah, 09h
        mov dx, offset chairString
        int 21h

        printCartMacro cart[1]

        ; Display Cupboard String
        mov ah, 09h
        mov dx, offset cupboardString
        int 21h

        printCartMacro cart[2]

        ; Display Message
        mov ah, 09h
        mov dx, offset cartTotal
        int 21h

        ; Display total price
        mov ax, total
        call displayInteger

        jmp cartInterfaceOptions      

cartInterfaceOptions:
        ; Display Message
        mov ah, 09h
        mov dx, offset cartOptions
        int 21h

        ; Character Input
        mov ah, 01h
        int 21h 

        ; Conditions
        cmp al, '1' ; Checkout
        je addSales

        cmp al, '2' ; Return back to main menu
        je returnCart

        jmp cartInputError ; Input not 1 or 2

addSales:

        ; Validation (total cant be 0)
        cmp total, 0
        je cartEmptyValidationError

        ; Add ax to totalSales
        mov ax, [total]
        add ax, [totalSales]
        mov [totalSales], ax
        mov total, 0 ; Reset total to 0

        ; Reseting Cart
        mov cart[0], 0
        mov cart[1], 0
        mov cart[2], 0

        ; Display Success Message
        mov ah, 09h
        mov dx, offset checkoutSuccessMessage
        int 21h

        jmp return

cartInputError:
        mov ah, 09h
        mov dx, offset invalidInput
        int 21h

        jmp printCart

cartEmptyValidationError:
        mov ah, 09h
        mov dx, offset cartEmptyValidationMessage
        int 21h

        jmp returnCart

returnCart:
        ret

checkoutProc endp

Main proc

        ; Initialize data segment
        mov ax, @data
        mov ds, ax    

        ; Ask user's username
        mov ah, 09h
        mov dx, offset askUsername
        int 21h

        ; Read String (Not Character)
        mov buffer[0], 21
        mov ah, 0Ah
        mov dx, offset buffer
        int 21h

        mov ah, 09h
        mov dx, offset greetingMessage
        int 21h

        mov bx, 2
        add bl, buffer[1]
        mov buffer[bx], '$'

        mov ah, 09h
        mov dx, offset buffer
        add dx, 2
        int 21h        

        jmp MainInterface

MainInterface:
        ; Display Message        
        mov ah, 09h
        mov dx, offset mainMenu
        int 21h 

        ; Character Input
        mov ah, 01h
        int 21h
        
        ; Conditions
        cmp al, '1'
        je purchaseItem ; Page that allow user to purchase furniture
        
        cmp al, '2'
        je displayTotalSale ; Page that displays total sales

        cmp al, '3'
        je InventoryTable ; Page that allow user to manage inventory

        cmp al, '4'
        je cartInterface ; Page that displays user's cart

        cmp al, '5'
        je exit ; Exit

        jmp error ; Invalid Input

cartInterface: ; Cart Interface
        call checkoutProc
        jmp MainInterface ; Go back to main interface

purchaseItem: ; Purchase Item
        call purchaseItemProc
        jmp MainInterface ; Go back to main interface

displayTotalSale: ; Total Sales code

        ; Display message
        mov ah, 09h
        mov dx, offset totalSalesHeader
        int 21h

        ; Display totalSales dw variable
        mov ax, totalSales
        call displayInteger

        jmp MainInterface ; Go back to main interface


InventoryTable: ; Manage Inventory code
        ; Display Header
        mov ah, 09h
        mov dx, offset manageInventoryHeader
        int 21h

        ; Display tableStock dw variable
        mov ax, tableStock
        call displayInteger

        ; Display Chair String
        mov ah, 09h
        mov dx, offset chairString
        int 21h

        ; Display chairStock dw variable
        mov ax, chairStock
        call displayInteger

        ; Display Cupboard String
        mov ah, 09h
        mov dx, offset cupboardString
        int 21h

        ; Display cupboardStock dw variable
        mov ax, cupboardStock
        call displayInteger

        jmp manageInventory ; Go back to main interface

manageInventory:
        ; Display Message
        mov ah, 09h
        mov dx, offset manageInventoryMenu
        int 21h

        ; Character Input
        mov ah, 01h
        int 21h

        ; Conditions
        cmp al, '1'
        je addStockInterface ; Page to Add Stock

        cmp al, '2'
        je MainInterface ; Go back to main interface

        jmp error ; Invalid Input

addStockInterface:

        call addStock
        jmp InventoryTable ; Go back to inventory table page

error:
        ; Display error message
        mov ah, 09h
        mov dx, offset invalidInput
        int 21h

        jmp MainInterface 

exit:
        ; Terminate Program
        mov ah, 4ch
        int 21h

main endp
end main
