// § invalidBlockLocFromSyntax244
package p;
  class base; function base get_comp(); return this; endfunction endclass
  class obj; endclass
  class pc #(type PORT = obj);
    PORT m;
    function void g(ref base list[string]);
      PORT list1[string];
      int k;
      k = 0;
      if (k == 0) begin
        foreach (list1[name]) begin
          list[name] = list1[name].get_comp();
        end
      end
      while (k < 1) begin
        k++;
        list["a"] = m.get_comp();
      end
      case (k)
        1: begin list["b"] = m.get_comp(); end
        default: ;
      endcase
    endfunction
  endclass
endpackage
module top;
endmodule
