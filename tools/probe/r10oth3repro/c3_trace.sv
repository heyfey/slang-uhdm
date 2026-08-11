// r10oth3 TARGET 1 arm c3 -- QUANTIFY the mutation, and find its WIDTH.
//
// Arm c1 established that golden(Surelog) OVERWRITES the RHS constant object of
// a compound assignment with the RESULT of the compound operation while it
// evaluates a constant function, and that the overwritten value FEEDS BACK as
// the operand on the next loop iteration.  For `x += <lit>` with the literal
// starting at r0 that predicts, over K iterations,
//
//     x_k = x_{k-1} + r_{k-1},   r_k = x_k        =>   r_K = r0 * 2^(K-1)
//
// so each row below has a CLOSED-FORM prediction, and the rows with large K say
// whether the wrap is 32-bit or 64-bit.  `i = i + 1` is a PLAIN assignment whose
// Rhs is an operation, so it carries no literal to corrupt and the trip count
// stays what the source says -- that is the control that keeps K known.
//
// Read with asgform.py.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

// K = 3  -> predict r = 2^2 = 4
module lf3;
  function automatic int fk(int m);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < m) begin
      x += 1;
      i = i + 1;
    end
    return x;
  endfunction
  localparam int P = fk(3);
endmodule

// K = 5  -> predict r = 2^4 = 16
module lf5;
  function automatic int fk(int m);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < m) begin
      x += 1;
      i = i + 1;
    end
    return x;
  endfunction
  localparam int P = fk(5);
endmodule

// K = 33 -> predict r = 2^32; 0 if the store wraps at 32 bits
module lf33;
  function automatic int fk(int m);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < m) begin
      x += 1;
      i = i + 1;
    end
    return x;
  endfunction
  localparam int P = fk(33);
endmodule

// K = 65 -> predict r = 2^64; 0 if the store wraps at 64 bits
module lf65;
  function automatic int fk(int m);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < m) begin
      x += 1;
      i = i + 1;
    end
    return x;
  endfunction
  localparam int P = fk(65);
endmodule

// CUMULATION ACROSS INSTANCES.  One module DEFINITION, two instantiations with
// different K.  The def view holds ONE copy of the function body, so if the
// mutation is cumulative across evaluations the surviving literal must be
// 2^((3-1)+(5-1)) = 64, not 2^(3-1) or 2^(5-1).  This is the cell that decides
// whether Rggen's head is a whole-design trace or a single evaluation.
module lfc #(parameter int K = 1);
  function automatic int fk(int m);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < m) begin
      x += 1;
      i = i + 1;
    end
    return x;
  endfunction
  localparam int P = fk(K);
endmodule

module c3top;
  lfc #(3) a();
  lfc #(5) b();
endmodule
