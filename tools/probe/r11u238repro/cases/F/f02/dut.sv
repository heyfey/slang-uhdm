// § foreachClassPropStringTsShared238
package p;
  class c;
    function void set_verb(string s);
      string values[$];
      values.push_back(s);
      foreach (values[i])
        if (values[i] == "x") values[i] = "y";
    endfunction
  endclass
endpackage
module top;
endmodule
