// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
  endclass
  class pc #(type PORT = base);
    function void get_connected_to(ref base list[string]);
      PORT list1[string];
      foreach(list1[name]) list[name] = list1[name].get_comp();
    endfunction
  endclass

endpackage
module top;
  p::pc #(p::base) w;
  initial w = new();
endmodule
