// § unitTdLawS245
// a $unit vector typedef on a $unit class property and a method local
typedef logic [3:0] nib_t;
class c;
  nib_t x;
  function nib_t get();
    nib_t t = x;
    return t;
  endfunction
endclass
module top(output logic [3:0] o);
  c h;
  initial begin h = new; o = h.get(); end
endmodule
