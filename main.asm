# Guess the Random Number

# Authors: Ekaterine Magradze and Luka Chitaishvili

# Github link of the repository: https://github.com/lchitaishvili/cs237-project

.data
	welcome: .asciiz "Welcome to Guess the Random Number!\n\n"
	prompt: .asciiz "Enter max value:\n"
	invalidUpperBound: .asciiz "Upper bound can't be less than 1. Please try again!\n"

	yourGuess: .asciiz "Random number generated! Please enter your guess:\n"
	toohigh: .asciiz "Too high! Try again:\n"
	toolow: .asciiz "Too low! Try again:\n"

	aboveUpperBound: .asciiz "Your guess is higher than the upper bound! Try a number between 1 and "
	belowLowerBound: .asciiz "Your guess is lower than 1! Try a number between 1 and "

	correct: .asciiz "Correct! The generated number was "
	numcount: .asciiz "Number of tries: "

.text
	main: 

	    # Print the welcome message
	    li $v0, 4		
	    la $a0, welcome				
	    syscall

	    # Prompt the user to enter max value
	    li $v0, 4				# Telling the computer that we are going to print some text
	    la $a0, prompt			# Gets the prompt text from above
	    syscall

	initialInput:

	    # Get user input
	    li $v0, 5				# Telling the computer that we want to get an integer from a user
	    syscall

	    # Store the result in $t0 temporarily
	    move $t0, $v0

	    blt $t0, 1, upperBoundLessThanOne 	# If upper bound is less than one
	    bge $t0, 1, validUpperBound       	# else
	    
	 upperBoundLessThanOne: 

	    li $v0, 4			
	    la $a0, invalidUpperBound  	 	# Print the invalidUpperBound message	
	    syscall

	    j initialInput  	     		# Return to the previous step	

	 validUpperBound:

	    move $a1, $t0
	    li $v0, 42				# Generated number will be at $a0
	    syscall

	    addi $a0, $a0, 1
	    move $t1, $a0			# Move Generated number to t1

	    #  Telling user to make a guess
	    li $v0, 4			
	    la $a0, yourGuess			
	    syscall

	    li $v0, 5
	    syscall					# Get user input (integer)

	    move $t2, $v0				# Move the input into $t2

	    addi $t3, $zero, 1	# count = 1 (number of tries)

	    while:

		beq $t2, $t1, exit 		# Branch to exit if equal; continue if not equal
		bgt $t2, $t0, higherThanMax     # if a user enters a value higher than upper bound
		blt $t2, 1, lowerThanOne 	# if a user enters a value lower than 1
		blt $t2, $t1, lower             # if a guess is lower

		# else
		li $v0, 4			# Print too high message
		la $a0, toohigh
		syscall

		addi $t3, $t3, 1		# count +=1

		li $v0, 5			# Get user input
		syscall

		move $t2, $v0			# Save the input into $t2

		j while

	    lower:

		li $v0, 4			# Print too low message
		la $a0, toolow			
		syscall

		addi $t3, $t3, 1		# count +=1

		li $v0, 5			# Get user input
		syscall

		move $t2, $v0			# Save the input into $t2

		j while

	     higherThanMax:
		
		li $v0, 4
		la $a0, aboveUpperBound		# Print aboveUpperBound message
		syscall
		
		li $v0, 1
		move $a0, $t0			# Print the upper bound
		syscall
		
		addi $a0, $zero, 10
		addi $v0, $zero, 11
		syscall 			# New Line
		
		addi $t3, $t3, 1		# count += 1
		
		li $v0, 5			# Get user input
		syscall			
		
		move $t2, $v0			# Save the input into t2
		
		j while

	    lowerThanOne:
		
		li $v0, 4			# Print the belowLowerBound message
		la $a0, belowLowerBound
		syscall
		
		li $v0, 1			# Add upper bound value to the message
		move $a0, $t0
		syscall
		
		addi $a0, $zero, 10
		addi $v0, $zero, 11
		syscall 			# New Line
		
		addi $t3, $t3, 1		# count += 1
		
		li $v0, 5			# Get user input
		syscall
		
		move $t2, $v0			# Save the input to t2
		
		j while	
		
	    exit: 
	    	li $v0, 4			# Print the message for correct guess
	    	la $a0, correct
	    	syscall
	    	
	    	li $v0, 1 			# Add generated number to the message
	    	move $a0, $t1
	    	syscall
	    	
	    	addi $a0, $zero, 10
		addi $v0, $zero, 11
		syscall 			# New Line
	    	
	    	li $v0, 4			# Print the numCount message
	    	la $a0, numcount
	    	syscall
	    	
	    	li $v0, 1			# Add the number of attemtps to the message
	    	move $a0, $t3
	    	syscall
	

# Handling interrupts

.kdata	
   	errMsg: .asciiz "Oops! Wrong input. Please try again!\n"

.ktext 0x80000180
   	move $k0,$v0   		# Save $v0 value
   	move $k1,$a0   		# Save $a0 value
   	la   $a0, errMsg  	
   	li   $v0, 4    		# Print the errMsg
   	syscall

   	move $v0,$k0   		# Restore $v0
   	move $a0,$k1   		# Restore $a0
   	mfc0 $k0,$14   		# Coprocessor 0 register $14 has address of trapping instruction
   	eret           		# Error return; set PC to value in $14
