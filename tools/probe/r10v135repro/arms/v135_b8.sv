// r10v135 (VERIFIER) ARM b8 — the index class name ALSO NAMES A MODULE, and an
// INSTANCE, and a GENVAR, in the importing top.  MUST NOT duplicate or shadow.
package pkgNameAlfa8;
  class modNameKilo8; int v; endclass
  class instNameLima8; int v; endclass
  class genNameMike8; int v; endclass
  class ownNovem8;
    extern function void oobOscar8();
  endclass
  function void ownNovem8::oobOscar8();
    bit n01ModName8  [modNameKilo8];
    bit n02InstName8 [instNameLima8];
    bit n03GenName8  [genNameMike8];
    n01ModName8.delete();
    n02InstName8.delete();
    n03GenName8.delete();
  endfunction
endpackage

module modNameKilo8;                     // a MODULE with the index class's name
  int mv8;
endmodule

module topNamePapa8;
  import pkgNameAlfa8::*;
  modNameKilo8 instNameLima8();          // an INSTANCE with another one's name
  ownNovem8 oQuebec8;
  genvar genNameMike8;                   // a GENVAR with a third one's name
  generate
    for (genNameMike8 = 0; genNameMike8 < 2; genNameMike8++) begin : gRomeo8
      initial begin end
    end
  endgenerate
  initial begin
    oQuebec8 = new();
    oQuebec8.oobOscar8();
  end
endmodule
