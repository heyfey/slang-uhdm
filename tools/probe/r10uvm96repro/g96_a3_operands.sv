// r10uvm96 arm 3 — THE OPERAND DOES NOT DECIDE THE TARGET KIND.
// `real'(<operand>)` over every operand shape the campaign has ever seen move
// a typespec, plus the sibling keywords on two of them so the arm cannot pass
// by agreeing on `real` alone.
module g96_a3;
  localparam int P = 7;
  int   v32;
  int   arr [4];
  logic [31:0] w;
  struct packed { logic [7:0] hi; logic [7:0] lo; } sp;
  typedef struct packed { logic [7:0] a; } st_t;
  st_t sv;
  int   i;
  real  out;
  function automatic int f(int x); return x; endfunction
  initial begin
    out = real'(v32);                 // bare variable
    out = real'(P);                   // parameter
    out = real'(7);                   // integer literal
    out = real'(3.5);                 // real literal
    out = real'(w[3]);                // bit-select
    out = real'(w[7:0]);              // part-select
    out = real'(w[i+:4]);             // indexed part-select
    out = real'(arr[2]);              // unpacked element
    out = real'(sp.hi);               // member
    out = real'(sv.a);                // typedef'd struct member
    out = real'(f(v32));              // function call
    out = real'({w[1:0], w[3:2]});    // concat
    out = real'(v32 + P);             // operation
    out = real'(int'(v32));           // nested cast (inner keyword too)
    out = real'((i > 0) ? v32 : P);   // ternary
    out = shortreal'(w[7:0]);         // sibling keyword, select operand
    out = realtime'(sp.hi);           // sibling keyword, member operand
  end
endmodule
