// r10uvm99 arm a4: CASE ... INSIDE items.
module delta99;
  int sel99, out99;
  always_comb begin
    case (sel99) inside
      [1:3]: out99 = 1;
      4, [6:8]: out99 = 2;
      9: out99 = 3;
      default: out99 = 0;
    endcase
  end
endmodule
