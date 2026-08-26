package pv158;
  class holder158 #(type T = int);
    function string f158();
      if (1) begin
        T t;
        t = T::type_id::create("t");
        f158 = {"x", t.get_name(), "y"};
      end
    endfunction
  endclass
endpackage
module top158;
  initial begin end
endmodule
