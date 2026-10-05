// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void get_connected_to(ref base list[string]);
      PORT list1[string];
      foreach(list1[name]) begin : nb
        list[name] = list1[name].get_comp();
      end
    endfunction
  endclass

endpackage
module top;
endmodule
