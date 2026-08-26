// v158 arm C — WHERE the rejected block lives.
package Hpk;
  class crate3;
    static function crate3 mk(string s); mk = new(); endfunction
    function string tag(); return "crate3"; endfunction
  endclass

  class Home3 #(type RR = int);
    // in-body FUNCTION
    function void inBody();
      if (1) begin
        RR aa3;
        aa3 = RR::mk("aa3");
      end
    endfunction
    // in-body TASK
    task inTask();
      if (1) begin
        RR bb3;
        bb3 = RR::mk("bb3");
      end
    endtask
    // STATIC method
    static function void inStatic();
      if (1) begin
        RR cc3;
        cc3 = RR::mk("cc3");
      end
    endfunction
    // CONSTRUCTOR
    function new();
      if (1) begin
        RR dd3;
        dd3 = RR::mk("dd3");
      end
    endfunction
    // OUT-OF-BODY declaration
    extern function void outBody();
    extern function void outOk();
  endclass

  function void Home3::outBody();
    if (1) begin
      RR ee3;
      ee3 = RR::mk("ee3");
    end
  endfunction

  // ACCEPTED out-of-body twin
  function void Home3::outOk();
    if (1) begin
      RR ff3;
      ff3 = 0;
    end
  endfunction

  // NON-PARAMETERIZED control — every block here must stay byte-identical.
  class Plain3;
    function void keep();
      if (1) begin
        int gg3;
        string hh3;
        gg3 = 2;
        hh3 = "keep";
      end
    endfunction
    task keept();
      begin : lab3
        int ii3;
        ii3 = 5;
      end
    endtask
  endclass
endpackage

module wtop_c;
  Hpk::Plain3 p3;
  initial begin
    p3 = new();
    p3.keep();
  end
endmodule
