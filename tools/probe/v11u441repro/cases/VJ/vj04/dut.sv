// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    for (int i = 0; i < 2; i++) begin
      garr[i]++;
      s++;
    end
    case (s)
      0: s++;
      default: garr[s]--;
    endcase
  endtask
endinterface
