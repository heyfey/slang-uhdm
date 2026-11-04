// § unitClassTdEndAtInit202 § unitClassTdSpecAtName202 § classSpecExprArgUnlocated202
// (a package variable of a $unit typedef is illegal in slang: 'cannot reference compilation unit item from within a package')
virtual class obj;
endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc;
  m_misc iv = new;
endinterface
program prg;
  m_misc qv = new;
endprogram
module top ();
  m_misc mv;
  ifc i();
  prg pr();
endmodule
