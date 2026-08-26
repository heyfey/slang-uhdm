// r10uvm158 grid, arm C — WHERE the rejected block lives.
// Every home is a GENERIC CLASS's default specialization (see arm B's header
// for why that is the whole silently-rejected population): an IN-BODY method,
// an OUT-OF-BODY method, a STATIC method, a TASK, a CONSTRUCTOR, a class that
// EXTENDS another, a class declared in a MODULE, one declared in an
// INTERFACE, one declared in a PROGRAM and one declared at `$unit` scope; a
// class with ONE and with TWO type parameters; and — as the controls — the
// same shape with an ACCEPTED statement and a NON-generic class next to it.
class unitC158 #(type T = int);            // $unit scope
  function void unitBody158();
    begin
      T uc158;
      uc158 = T::mk158("uc158");
    end
  endfunction
endclass

package pc158;

  class payl158;
    static function payl158 mk158(string s); mk158 = new(); endfunction
  endclass

  class baseC158;
    function new(); endfunction
  endclass

  class hostC158 #(type T = int) extends baseC158;   // EXTENDS
    string sink158 = "";
    // (1) IN-BODY method.
    function void inBody158();
      begin
        T hb158;
        hb158 = T::mk158("hb158");
      end
    endfunction
    // (2) OUT-OF-BODY method (prototype here, body below), and its ACCEPTED
    //     twin: the two answer the same question about an out-of-body
    //     type-parameter local, one through the recovered scope and one
    //     through the ordinary block path.
    extern function void outBody158();
    extern function void outOk158();
    // (3) a STATIC method.
    static function void statBody158();
      begin
        T sb158;
        sb158 = T::mk158("sb158");
      end
    endfunction
    // (4) a TASK.
    task tkBody158();
      begin
        T tb158;
        tb158 = T::mk158("tb158");
      end
    endtask
    // (5) a CONSTRUCTOR.
    function new();
      super.new();
      begin
        T cb158;
        cb158 = T::mk158("cb158");
      end
    endfunction
    // (6) the ACCEPTED control in the SAME class.
    function void okBody158();
      begin
        T ok158;
        int oi158;
        oi158 = 1;
      end
    endfunction
  endclass

  function void hostC158::outBody158();
    begin
      T ob158;
      ob158 = T::mk158("ob158");
    end
  endfunction

  function void hostC158::outOk158();
    begin
      T oo158;
      int oj158;
      oj158 = 3;
    end
  endfunction

  // (7) TWO type parameters.
  class twoC158 #(type T = int, type V = int);
    function void twoBody158();
      begin
        T t2a158;
        V t2b158;
        t2a158 = T::mk158("t2158");
      end
    endfunction
  endclass

  // (8) a NON-generic class — nothing here can be silently rejected, so it is
  //     the negative control for the whole arm.
  class plainC158;
    function void plainBody158();
      begin
        int pb158;
        pb158 = 4;
      end
    endfunction
  endclass

endpackage

interface ifc158;
  class ifC158 #(type T = int);              // declared in an INTERFACE
    function void ifBody158();
      begin
        T ifv158;
        ifv158 = T::mk158("ifv158");
      end
    endfunction
  endclass
endinterface

program prgc158;
  class prC158 #(type T = int);              // declared in a PROGRAM
    function void prBody158();
      begin
        T prv158;
        prv158 = T::mk158("prv158");
      end
    endfunction
  endclass
  initial begin
    $display("c158p");
  end
endprogram

module topc158;
  class modC158 #(type T = int);             // declared in a MODULE
    function void modBody158();
      begin
        T mv158;
        mv158 = T::mk158("mv158");
      end
    endfunction
  endclass
  initial begin
    int mi158;
    mi158 = 1;
  end
endmodule
