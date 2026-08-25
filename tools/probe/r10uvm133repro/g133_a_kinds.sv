// r10uvm133 arm A - $bits ARGUMENT KINDS inside a class method.
// MEASUREMENT ONLY.  LHS is always golden (Surelog).
package p133_a;

  typedef struct packed { bit [7:0] hi; bit [3:0] lo; } st133_t;
  typedef bit [5:0] w6133_t;

  parameter int PW133 = 12;

  class kinds133_c;
    string     q_str[$];
    int        q_int[$];
    bit [7:0]  arr8 [4];
    st133_t    s_mem;
    int        i_var;
    bit [15:0] v16;
    localparam int LP133 = 7;

    function int f_free133();
      return 3;
    endfunction

    function void probe133();
      int r;
      r = $bits(int);                 // K01 type keyword
      r = $bits(w6133_t);             // K02 typedef
      r = $bits(st133_t);             // K03 struct typedef
      r = $bits(5);                   // K04 literal
      r = $bits(PW133);               // K05 package parameter
      r = $bits(LP133);               // K06 class localparam
      r = $bits(i_var);               // K07 plain property
      r = $bits(v16[3]);              // K08 element select
      r = $bits(v16[7:0]);            // K09 range select
      r = $bits(s_mem.hi);            // K10 member access
      r = $bits(arr8[2]);             // K11 array element
      r = $bits(q_str.size());        // K12 METHOD CALL on a string queue
      r = $bits(q_int.size());        // K13 METHOD CALL on an int queue
      r = $bits(f_free133());         // K14 bare method call
      r = $bits(this.f_free133());    // K15 this-qualified method call
      r = $bits(i_var + 1);           // K16 binary expression
      r = $bits(~i_var);              // K17 unary expression
      r = $bits(q_int.sum());         // K18 reduction method call
      r = $bits(s_mem);               // K19 whole struct property
      r = $bits(arr8);                // K20 whole unpacked array
      if (r == 0) r = 1;
    endfunction
  endclass
endpackage
