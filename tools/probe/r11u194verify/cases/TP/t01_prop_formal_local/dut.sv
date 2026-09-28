// § typeParamUseSharesOwnTs183 § typeParamDefersToTpUse186 § typeParamGateNoLookup186: a class type parameter used as a property type, a method formal, a return type and a method local, with a keyword default
package p;
  class holder #(type H = int);
    H prop;
    H arr[2];
    function H get(H a);
      H loc;
      loc = a;
      return loc;
    endfunction
  endclass
  class user;
    holder #(byte) hb;
  endclass
endpackage
module top; endmodule
