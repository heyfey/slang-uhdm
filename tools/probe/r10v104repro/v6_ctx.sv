// v104 arm V6 - CONTEXT: the same stringification in $unit, a package, a
// module, a class; as parameter / localparam / assignment Rhs / $display /
// $sformatf / case item / concatenation; three instances of the module.
`define CN wxy
`define CA 3
`define CS `"`CN``_```CA``,``tail`"
parameter string unit_par = `CS;
package v6_pk;
  parameter  string pk_par = `CS;
  localparam string pk_loc = `CS;
  class v6_cls;
    localparam string cl_loc = `CS;
    string cs;
    function void go();
      cs = `CS;
      $display(`CS);
      cs = $sformatf("%s", `CS);
      cs = {`CS, "-x", `CS};
    endfunction
  endclass
endpackage
module v6_sub;
  parameter  string m_par = `CS;
  localparam string m_loc = `CS;
  string w;
  initial begin
    w = `CS;
    $display(`CS);
    w = $sformatf("[%s]", `CS);
    w = {`CS, `CS};
    case (w)
      `CS: w = "hit";
      default: w = "miss";
    endcase
  end
endmodule
module v6_top;
  v6_sub i0();
  v6_sub i1();
  v6_sub i2();
endmodule
