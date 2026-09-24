// r10v96 arm 4 — the SAME moving keyword over every OPERAND kind.
package v96p4;
  typedef struct packed { bit [7:0] a; bit [7:0] b; } sp_t;
  parameter int PK = 5;
  function automatic int g(int a); return a; endfunction
  function automatic void f4();
    logic [31:0] v;
    logic [3:0]  u [0:3];
    sp_t         sv;
    int          i;
    real         rr;
    rr = real'(v);                    // bare var
    rr = real'(PK);                   // parameter
    rr = real'(7);                    // int literal
    rr = real'(2.75);                 // real literal
    rr = real'(v[3]);                 // bit-select
    rr = real'(v[7:0]);               // part-select
    rr = real'(v[i +: 4]);            // indexed part-select
    rr = real'(u[2]);                 // unpacked element
    rr = real'(sv.a);                 // member
    rr = real'(g(3));                 // call
    rr = real'({v[1], v[0]});         // concat
    rr = real'(v + 1);                // operation
    rr = real'(int'(v));              // nested cast (control inside)
    rr = real'(integer'(v));          // nested cast (mover inside)
    rr = real'(i ? v : 32'd0);        // ternary
    rr = shortreal'(v[3]);            // second keyword, same operand
    rr = longint'(v[7:0]);
    rr = time'(u[1]);
    rr = realtime'(sv.b);
    rr = shortint'({v[1], v[0]});
    $display("%0f", rr);
  endfunction
endpackage
