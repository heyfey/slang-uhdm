// § unitClassTdEndAtInitIfcPrg206 § hiddenBlockVarMintNoFile207 (a $unit class typedef variable in an interface of a .sv file; a .v module with a hidden block variable instantiating it)
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, string) m_misc;
interface ifc ();
  m_misc a =
     new;
endinterface
