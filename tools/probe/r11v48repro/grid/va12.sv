// va12 — an ARRAY and a STRUCT body local as call arguments in the return
// expression of a never-evaluated package function.
package va12p;
  typedef struct packed { logic [3:0] a; } st_t;
  function automatic int unsigned ws(st_t s); return s.a; endfunction
  function automatic int unsigned wa(logic [3:0] a); return a; endfunction
  function automatic int unsigned f(input logic [3:0] n);
    st_t s;
    logic [3:0] arr;
    s.a = n; arr = n;
    return ws(s) + wa(arr);
  endfunction
endpackage
module va12 (input logic c, output logic o);
  assign o = c;
endmodule
