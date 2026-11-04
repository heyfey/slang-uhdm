// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void get_connected_to(ref base list[string]);
      PORT list1[string];
      for (int i = 0; i < 2; i++) begin
        list["a"] = list1["a"].get_comp();
      end
    endfunction
  endclass

endpackage
module top;
endmodule
