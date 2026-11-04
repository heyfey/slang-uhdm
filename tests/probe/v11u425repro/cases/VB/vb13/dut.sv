// § oneTickUpperBNormalized425
class C;
  bit b;
  function void set();
    b = 1'B1;
  endfunction
endclass
module top(output logic y);
  initial begin
    C c = new;
    c.set();
  end
  assign y = 1'B0;
endmodule
