// § tfArgTypedefLastWriter146
interface ifc;
  typedef enum logic [1:0] {A, B, C} e_t;
  e_t s;
  function automatic logic isa(e_t x); return x == A; endfunction
endinterface
module top(output logic o);
  ifc u(); assign o = u.isa(u.s);
endmodule
