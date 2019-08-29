.data
n: .word 
adj: .space 250000 # (500 x 500) bytes
cost: .space 250000 # (500 x 500) bytes
visited: .space 2000 # 500 integers
distance: .space 2000 # 500 integers
parent: .space 2000 # 500 integers
priority_queue: .space 10004
aqui: .asciiz "aqui"
comecando_dijkstra: .asciiz "Começando Dijkstra..."
fim_dijkstra: .asciiz "...fim do Dijkstra"
visitando: .asciiz "Visitando "
relaxando: .asciiz "Relaxando "

.text

main:
    li $v0, 5
    syscall
    move $s0, $v0
    
    li $v0, 5
    syscall
    move $s1, $v0
    
    li $v0, 1
    move $a0, $s0
    syscall
    li $v0, 11
    li $a0, 32
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 11
    li $a0, 10
    syscall
    
    # for(i = 0;i < m;i++){
    #     scanf("%d%d", u, v);
    #     scanf("%d", cost[u][v]);
    #     adj[u][v] = 1
    #	  adj[v][u] = 1
    # }

    li $t0, 0
    main_read_input_loop:
    	# u: $t1
    	# v: $t2
    	# w: $t3
    	li $v0, 5
    	syscall
	move $t1, $v0
	li $v0, 5
    	syscall
	move $t2, $v0
	li $v0, 5
    	syscall
	move $t3, $v0
    	
 	# offset: $t4
 	mul $t4, $t1, $s0 # u * n
 	add $t4, $t4, $t2 # u * n + v
 	sll $t4, $t4, 2 # offset * 4
 	la $t5, adj
 	add $t5, $t5, $t4
 	sw $t3, 0($t5)
 	la $t5, cost
 	add $t5, $t5, $t4
 	sw $t3, 0($t5)
 	
 	mul $t4, $t2, $s0 # v * n
 	add $t4, $t4, $t1 # v * n + u
 	sll $t4, $t4, 2 # offset * 4
 	la $t5, adj
 	add $t5, $t5, $t4
 	sw $t3, 0($t5)
 	la $t5, cost
 	add $t5, $t5, $t4
 	sw $t3, 0($t5)
    	   
    	addi $t0, $t0, 1
        blt $t0, $s1, main_read_input_loop     
    
    move $a1, $s0
    li $a2, 0x7FFFFFFF
    
    la $a0, distance
    jal fill_word_array
    la $a0, parent
    li $a2, -1
    jal fill_word_array
    
    li $v0, 4
    la $a0, comecando_dijkstra
    syscall
    
    li $v0, 11
    li $a0, 10
    syscall
    
    li $v0, 5
    syscall
    move $s2, $v0 # source
    
    move $a0, $s2
    move $a1, $s0
    jal dijkstra
    
    li $v0, 4
    la $a0, fim_dijkstra
    syscall
    
    li $v0, 11
    li $a0, 10
    syscall
    
    la $a0, distance
    move $a1, $s0
    jal print_array
    
    li $v0, 10
    syscall

dijkstra:
    # $a0: source
    # $a1: n
    
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    
    move $s1, $a0 # source
    move $s3, $a1 # n
    
    sll $t0, $s1, 2 # $t0 = 4 * $s0

    la $t1, distance
    add $t1, $t1, $t0
    sw $zero, 0($t1) # distance[source] = 0
    
    la $a0, priority_queue
    li $a1, 0
    move $a2, $s1
    jal min_heap_insert # enqueue({source, 0})

    dijkstra_loop:
    	la $t0, priority_queue
        lw $t1, 0($t0) 
        beq $t1, $zero, dijkstra_loop_exit
            move $a0, $t0
            jal min_heap_remove
            
            move $s2, $v1 # current = pop(priority_queue)
            
            li $v0, 4
            la $a0, visitando
            syscall
            li $v0, 1
            move $a0, $s2
            syscall
            li $v0, 11
            li $a0, 10
            syscall
            
            la $t0, adj
            la $t2, cost
            mul $t1, $s2, $s1 # current * columns
            sll $t1, $t1, 2
            add $t0, $t0, $t1 # $t0 = adj[current]
            add $t2, $t2, $t1 # $t2 = cost[current]
            
            li $t3, 0
            dijkstra_neighbours_loop:
                sll $t4, $t3, 2 # j offset
                add $t5, $t4, $t0
                lw $t5, 0($t5) # adj[current][j]
                
                li $v0, 1
                move $a0, $t5
                syscall
              	li $v0, 11
                li $a0, 10
                syscall
                
                beqz $t5, dijkstra_neighbours_exit
                la $t5, visited
                add $t5, $t5, $t4
                lw $t5, 0($t5) # visited[j]
                bnez $t5, dijkstra_neighbours_exit
                add $t5, $t4, $t2
                lw $t5, 0($t5) # cost[current][j]
                
                sll $t6, $s2, 2
                la $t7, distance
                add $t6, $t6, $t7
                lw $t6, 0($t6) # distance[current]
		add $t7, $t7, $t4
                lw $t7, 0($t7) # distance[j]
                add $t6, $t6, $t5 # distance[current] + cost[i][j]
                
                li $v0, 1
                move $a0, $t7
                syscall
                li $v0, 11
                li $a0, 32
                syscall
                li $v0, 1
                move $a0, $t6
                syscall
              	li $v0, 11
                li $a0, 10
                syscall
                
                bge $t6, $t7, dijkstra_dont_relax
                
                li $v0, 4
                la $a0, relaxando
                syscall
                li $v0, 1
                move $a0, $t3
                syscall
                li $v0, 11
                li $a0, 10
                syscall
                
                la $t7, distance
                add $t7, $t7, $t4
                sw $t6, 0($t7) # distance[j] = distance[current] + cost[i][j]
                la $t7, parent
                add $t7, $t7, $t4
                sw $s2, 0($t7) # parent[j] = current
                
                la $a0, priority_queue
                move $a1, $t6
                move $a2, $t3
          	jal min_heap_insert
                
                dijkstra_dont_relax:
            
            dijkstra_neighbours_exit:
            addi $t3, $t3, 1
            blt $t3, $s3, dijkstra_neighbours_loop
            # visited[current] = 1
    
    dijkstra_loop_exit:
    
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 12
    jr $ra

fill_word_array:
    # $a0: array
    # $a1: size
    # $a2: value

    li $t0, 0
    fill_word_array_loop:
        sll $t1, $t0, 2
        add $t1, $a0, $t1

        sw $a2, 0($t1)

	addi $t0, $t0, 1
        blt $t0, $a1, fill_word_array_loop

    jr $ra

mem_word_copy:
    # $a0: first base address
    # $a1: buffer
    # $a2: size
    
    li $t0, 0
    
    mem_word_copy_loop:
    	lw $t1, 0($a0)
   	sw $t1, 0($a1)
    	
    	addi $a0, $a0, 4
    	addi $a1, $a1, 4
    	
    	addi $t0, $t0, 1		
        ble $t0, $a2, mem_word_swap_loop
        
    jr $ra
    

mem_word_swap:
    # $a0: first base address
    # $a1: second base address
    # $a2: size
    
    li $t0, 0
    
    mem_word_swap_loop:
    	lw $t1, 0($a0)
    	lw $t2, 0($a1)
    	
    	sw $t1, 0($a1)
    	sw $t2, 0($a0)
    	
    	addi $a0, $a0, 4
    	addi $a1, $a1, 4
    	
    	addi $t0, $t0, 1		
        blt $t0, $a2, mem_word_swap_loop
        
    jr $ra

# Min-Heap{
#     size,
#     data
# }

min_heap_remove:
    # $a0: heap address
    
    # $v0: priority
    # $v1: index
    
    # $v0 = $s0[1]
    # $v1 = $s0[2]
    # $s[1...2] <-> $s[$s[0] - 2...$s[0]]
    # $s[0]--

    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0
    
    lw $s1, 0($s0)
    lw $v0, 4($s0)
    lw $v1, 8($s0)

    addi $t1, $s1, -1
    sll $t1, $t1, 3
    add $t1, $s0, $t1
    addi $t1, $t1, 4
    
    addi $s2, $s0, 4
    
    move $a0, $s2
    move $a1, $t1
    li $a2, 2
    jal mem_word_swap

    addi $s1, $s1, -1
    sw $s1, 0($s0)

    move $a0, $s2
    move $a1, $s1
    li $a2, 0
    jal min_heapify
 
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12

    jr $ra

min_heap_insert:
    # $a0: heap address
    # $a1: priority
    # $a2: vertex
    
    # $s0: heap data
    # $t0: heap size
    # $t1: inserted address
    # $s1: child index
    # $s2: parent index
    
    # $s0[$t0] = {$a1, $a2}
    # $s1 = $t0
    # $s2 = ($t0 - 1)/2
    # 
    # while($s0[$s2][0] > $s0[$s1][0]){
    #     $s0[$s2] <-> $s0[$s1]
    #     $s1 = $s2
    #     $s2 = ($s2 - 1) / 2
    # }
    #
    # size++
    
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $a0, 20($sp)
       
    lw $s3, 0($a0)
    move $s0, $a0
    addi $s0, $s0, 4
    
    sll $t1, $s3, 3
    add $t1, $t1, $s0
    sw $a1, 0($t1)
    sw $a2, 4($t1)
    
    move $s1, $s3
    addiu $s2, $s3, -1
    blez $s2, min_heap_insert_loop
    srl $s2, $s2, 1
    
    min_heap_insert_loop:
    bltz $s2, min_heap_insert_exit_loop
    
    sll $t2, $s2, 3
    add $t2, $t2, $s0
    lw $t3, 0($t2)
    sll $t4, $s1, 3
    add $t4, $t4, $s0
    lw $t5, 0($t4)
    
    ble $t3, $t5, min_heap_insert_exit_loop
        move $a0, $t2 
        move $a1, $t4
        li $a2, 2
        jal mem_word_swap
        
        lw $a0, 20($sp)
        move $s1, $s2
        addi $s2, $s2, -1
        blez $s2, min_heap_insert_loop
        srl $s2, $s2, 1
                        
    j min_heap_insert_loop
    min_heap_insert_exit_loop:
    
    addi $s3, $s3, 1
    sw $s3, 0($a0)
    
   
    lw $s3, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 24
    
    jr $ra

min_heapify:
    # $a0: base address
    # $a1: size
    # $a2: index
    
    # $t1 = $a2 * 2 + 1
    # $t2 = $a2 * 2 + 2
    #
    # $t0 = $a2
    #
    # if($t1 < $a1 && $a0[$t1][0] < $a0[$t0][0])
    #     $t0 = $t1
    # if($t2 < $a1 && $a0[$t2][0] < $a0[$t0][0])
    #     $t0 = $t2
    #
    # if($t0 != $a2)
    #     $a0[$a2] <-> $a0[$t0]
    #     min_heapify($a0, $a1, $t0)
    
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    
    
    add $t0, $a2, $a2
    addi $t1, $t0, 1
    addi $t2, $t0, 2
    
    move $t0, $a2
    
    bge $t1, $a1, min_heapify_exit_if_1
	sll $t3, $t1, 3
	add $t3, $a0, $t3
	lw $t3, 0($t3)
	
	sll $t4, $t0, 3
	add $t4, $a0, $t4
	lw $t4, 0($t4)
	
        bge $t3, $t4, min_heapify_exit_if_1
            move $t0, $t1
    min_heapify_exit_if_1:
    
    bge $t2, $a1, min_heapify_exit_if_2
	sll $t3, $t2, 3
	add $t3, $a0, $t3
	lw $t3, 0($t3)
	
	sll $t4, $t0, 3
	add $t4, $a0, $t4
	lw $t4, 0($t4)
	
        bge $t3, $t4, min_heapify_exit_if_2
            move $t0, $t2
    min_heapify_exit_if_2:
    
    beq $t0, $a2, min_heapify_exit
        sll $t3, $t0, 3
        add $t3, $a0, $t3
    
        sll $t5, $a2, 3
        add $t5, $a0, $t5
        
        move $a0, $t3
        move $a1, $t5
       	li $a2, 2
        jal mem_word_swap
        
        lw $a2, -12($sp)
        lw $a1, -8($sp)
        lw $a0, -4($sp)
        
        move $a2, $t0
        jal min_heapify
    
    min_heapify_exit:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    
    jr $ra
  
print_array:
    # $a0: base address
    # $a1: size
        
    li $t1, 0
    move $t0, $a0
    main_loop_print:
        lw $a0, 0($t0)
        li $v0, 1
        syscall

        li $v0, 11
        li $a0, 32
        syscall

	addi $t0, $t0, 4
	addi $t1, $t1, 1
        blt $t1, $a1, main_loop_print   
    
    li $v0, 11
    li $a0, 10
    syscall
    
    jr $ra
