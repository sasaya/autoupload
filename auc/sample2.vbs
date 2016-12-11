'''
''' TS�G���R�[�h�̃o�b�`�o�^ �T���v���X�N���v�g
'''
' �����̃t�@�C���S���ɂ��āA
' BonTsDemux�ŕ�������AviUtl�Ƀo�b�`�o�^����X�N���v�g
' TS�t�@�C�����h���b�O���AVBS�Ƀh���b�v���Ďg�p����
' �o�b�`�o�͒���AviUtl�ɑ΂��āA�o�b�`��ǉ��o�^�ł���

On Error Resume Next

Set Args = WScript.Arguments

' �e���|�����p�X
Const TMP_FOLDER = "C:\MOVTEMP\"

' �G���R�[�h�����f�[�^���o�͂���t�H���_(�Ō�̕�����"\")
Const OUTPUT_FOLDER = "D:\VIDEO\"

' �v���t�@�C���ԍ�(���j���[�̈�ԏオ0)
Const OUTPUT_PROFILE = 0

' �o�̓v���O�C���ԍ�(���j���[�̈�ԏオ0)
Const OUTPUT_PLUGIN = 2

' �o�̓t�@�C���̊g���q
Const OUTPUT_EXT = ".wmv"

' BonTsDemux�̃t���p�X
Const BonTsDemux_PATH = "C:\Program Files\BonTsDemux\BonTsDemux.exe"

' mme�̃t���p�X
Const mme_PATH = "C:\Program Files\m2vfp\mme.exe"

' AviUtl�̃t���p�X
Const AVIUTL_PATH = "C:\Program Files\aviutl\aviutl.exe"

' AviUtl Control��u���Ă���t�H���_(�Ō�̕�����"\")
Const AUC_FOLDER = "C:\Program Files\auc\" ' = �X�N���v�g�Ɠ����t�H���_

Dim WHSHell, oExec, Fs
Set WSHShell = WScript.CreateObject("WScript.Shell")
Set Fs = CreateObject("Scripting.FileSystemObject")

Function Auc(command, arg)
  Auc = WSHShell.Run("""" & AUC_FOLDER & "auc_" & command & ".exe"" " & arg, 2, True)
End Function

Dim i, tmp, tmpm2v, tmpwav, tmpgl, output, pid, hwnd

' AviUtl���N��
hwnd = Auc("exec", """" & AVIUTL_PATH & """")
If hwnd = 0 Then
  Call WScript.Quit(-1)
End if

For i=0 to Args.Count - 1
  tmp = TMP_FOLDER & Fs.GetBaseName(Args(i))
  tmpm2v = tmp & ".m2v"
  tmpwav = tmp & ".wav"
  tmpgl = tmp & ".gl"
  output = OUTPUT_FOLDER & Fs.GetBaseName(Args(i)) & OUTPUT_EXT
  
  ' TS�t�@�C���𕪊�
  Call WSHShell.Run("""" & BonTsDemux_PATH & """" & " -i """ & Args(i) & """ -o """ & tmp & """ -vf -start -quit", 0, True)
  
  ' gl�t�@�C�����쐬
  Call WSHShell.Run("""" & mme_PATH & """ -g -q """ & tmpm2v & """", 0, True)
  
  ' M2V�t�@�C�����J��
  Call Auc("open", CStr(hwnd) & " """ & tmpm2v & """")
  Call WScript.Sleep(3000)
  
  ' WAV�t�@�C�����J��
  Call Auc("audioadd", CStr(hwnd) & " """ & tmpwav & """")
  Call WScript.Sleep(3000)
  
  ' �v���t�@�C����ݒ肷��
  Call Auc("setprof", CStr(hwnd) & " " & CStr(OUTPUT_PROFILE))
  Call WScript.Sleep(3000)
  
  ' �o�̓v���O�C������o�͂���
  Call Auc("plugbatch", CStr(hwnd) & " " & CStr(OUTPUT_PLUGIN) & " """ & output & """")
  Call WScript.Sleep(3000)
  
  ' �t�@�C�������
  Call Auc("close", CStr(hwnd))
  
  ' �e���|�����t�@�C�����폜����
  Call Fs.Delete(tmpm2v)
  Call Fs.Delete(tmpwav)
  Call Fs.Delete(tmpgl)

Next

' �X�N���v�g�ŋN������AviUtl���I������
Call Auc("exit", CStr(hwnd))

