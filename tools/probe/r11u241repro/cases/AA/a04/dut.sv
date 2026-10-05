// § cloneLocalArrayTsParented241
package quarrycv204;
  class Leafcv204;
    int orecv204;
    function void assaycv204(int v204);
    endfunction
  endclass
  class Itercv204;
    function Leafcv204 firstcv204();
      return null;
    endfunction
    function Leafcv204 nextcv204();
      return null;
    endfunction
  endclass
  class Aditcv204;
    int sinkcv204;
    extern function void winzecv204(int selcv204);
  endclass
  function void Aditcv204::winzecv204(int selcv204);
    Itercv204 itcv204;
    Leafcv204 sqcv204[string];
    itcv204 = new();
    sqcv204["a"] = null;
    if (selcv204 == 1) begin
      for (Leafcv204 cCv204 = itcv204.firstcv204(); cCv204 != null; cCv204 = itcv204.nextcv204())
        cCv204.assaycv204(1);
    end
    else begin
      for (int iCv204 = 0; iCv204 < 4; iCv204++)
        this.sinkcv204 = iCv204;
    end
  endfunction
endpackage

package alphacv204;
  import quarrycv204::*;
  class Aflumecv204;
    function void aracecv204();
      Aditcv204 agatecv204;
      agatecv204 = null;
    endfunction
  endclass
endpackage

package betacv204;
  import quarrycv204::*;
  class Bflumecv204;
    function void bracecv204();
      Aditcv204 bgatecv204;
      bgatecv204 = null;
    endfunction
  endclass
endpackage

module topcv204;
  import alphacv204::*;
  import betacv204::*;
  initial begin
    Aflumecv204 a204;
    Bflumecv204 b204;
    a204 = new();
    b204 = new();
    a204.aracecv204();
    b204.bracecv204();
  end
endmodule
