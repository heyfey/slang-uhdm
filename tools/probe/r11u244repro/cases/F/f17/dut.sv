// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void get_connected_to(ref base list[string]);
      PORT list1[string];
      foreach(list1[name]) begin
        base t;
        t = list1[name].get_comp();
        list[name] = t;
      end
    endfunction
  endclass

endpackage
module top;
endmodule
