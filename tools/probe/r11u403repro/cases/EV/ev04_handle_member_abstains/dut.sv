// § unboundEventImplicitNet403
class C;
  event e;
endclass
module top;
  C h;
  initial begin
    h = new;
    -> h.e;
    @(h.e);
  end
endmodule
