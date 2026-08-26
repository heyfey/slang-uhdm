// v158 arm G — a generic class in a $unit / package / interface / program home.
class Root6 #(type VV = int);       // $unit home
  function void spin();
    if (1) begin
      VV ww6;
      ww6 = VV::type_id::create("ww6");
    end
  endfunction
endclass

package Ppk6;
  class Inpk6 #(type VV = int);
    function void spin();
      if (1) begin
        VV xx6;
        xx6 = VV::type_id::create("xx6");
      end
    endfunction
  endclass
endpackage

interface iface6;
  class Inif6 #(type VV = int);
    function void spin();
      if (1) begin
        VV yy6;
        yy6 = VV::type_id::create("yy6");
      end
    endfunction
  endclass
endinterface

program prog6;
  class Inpg6 #(type VV = int);
    function void spin();
      if (1) begin
        VV zz6;
        zz6 = VV::type_id::create("zz6");
      end
    endfunction
  endclass
  initial begin
    int keep6;
    keep6 = 1;
  end
endprogram

module wtop_g;
  iface6 if6();
  class Inmd6 #(type VV = int);
    function void spin();
      if (1) begin
        VV ab6;
        ab6 = VV::type_id::create("ab6");
      end
    endfunction
  endclass
  initial begin
    int cd6;
    cd6 = 2;
  end
endmodule
