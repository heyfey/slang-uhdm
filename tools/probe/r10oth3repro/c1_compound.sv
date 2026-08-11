// r10oth3 TARGET 1 arm c1 -- WHERE does Surelog give a compound-assignment RHS
// literal the value 0?
//
// Rggen's head is `list_index += 1;` (rggen_or_reducer.sv:30) inside a constant
// function that a localparam CALLS.  golden(Surelog) writes that literal's
// value as 0; we write 1.  This arm varies, one row per statement, the three
// things the brief named: the CONTEXT (constant function that is called / a
// function nobody calls / always_comb / initial), the LOOP (straight-line vs
// inside a while), and the OPERATOR/LITERAL.
//
// Read with asgform.py: each `assignment` prints its vpiOpType and its Rhs.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module c1;
  // A -- constant function, straight-line, CALLED from a localparam
  function automatic int fa(int n);
    int x;
    x = 0;
    x += 1;                      // A1  line 19
    x -= 1;                      // A2  line 20
    x *= 2;                      // A3  line 21
    x <<= 1;                     // A4  line 22
    x += 7;                      // A5  line 23
    x += 0;                      // A6  line 24
    return x;
  endfunction
  localparam int PA = fa(3);

  // B -- identical function body, NOT called in any constant context
  function automatic int fb(int n);
    int x;
    x = 0;
    x += 1;                      // B1  line 33
    x -= 1;                      // B2  line 34
    x *= 2;                      // B3  line 35
    x <<= 1;                     // B4  line 36
    x += 7;                      // B5  line 37
    x += 0;                      // B6  line 38
    return x;
  endfunction

  // C -- constant function, the compound assignments INSIDE A WHILE LOOP,
  //      called from a localparam.  This is Rggen's exact shape.
  function automatic int fc(int n);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < n) begin
      x += 1;                    // C1  line 51
      x += 7;                    // C2  line 52
      i += 1;                    // C3  line 53
    end
    return x;
  endfunction
  localparam int PC = fc(3);

  // D -- same while shape, function NOT called in a constant context
  function automatic int fd(int n);
    int x;
    int i;
    x = 0;
    i = 0;
    while (i < n) begin
      x += 1;                    // D1  line 67
      x += 7;                    // D2  line 68
      i += 1;                    // D3  line 69
    end
    return x;
  endfunction

  // E -- procedural blocks, no function at all
  int ey;
  always_comb begin
    ey = 0;
    ey += 1;                     // E1  line 78
    ey += 7;                     // E2  line 79
  end

  int ez;
  initial begin
    ez = 0;
    ez += 1;                     // F1  line 85
    ez += 7;                     // F2  line 86
  end

  // G -- plain (non-compound) assignments of the same literals, as the control
  //      that says whether the zeroing is about `+=` at all
  function automatic int fg(int n);
    int x;
    x = 1;                       // G1  line 93
    x = 7;                       // G2  line 94
    x = x + 1;                   // G3  line 95
    return x;
  endfunction
  localparam int PG = fg(3);
endmodule
