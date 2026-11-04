// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
  endclass
  class pcb; virtual function void get_connected_to(ref base list[string]); endfunction endclass
  class pc #(type PORT = base) extends pcb;
    virtual function void get_connected_to(ref base list[string]);
      PORT list1[string];
      list.delete();
      foreach(list1[name]) begin
        list[name] = list1[name].get_comp();
      end
    endfunction
  endclass

endpackage
module top;
endmodule
