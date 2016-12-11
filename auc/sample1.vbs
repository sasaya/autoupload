'''
''' AviUtl�G���R�[�h���t�@�C���ړ� �T���v���X�N���v�g
'''
' ����t�H���_�̒��̃t�@�C���S���ɂ��āA
' �v���t�@�C�����o�̓v���O�C���w��ŃG���R�[�h���A
' �G���R�[�h���I�������w��̃t�H���_�Ɉړ�����X�N���v�g

On Error Resume Next

' �L���v�`�������t�@�C��������t�H���_(�Ō�̕�����"\")
Const SOURCE_FOLDER  = "D:\CAPTURE\"

' �G���R�[�h���I������t�@�C�����ڂ��t�H���_(�Ō�̕�����"\")
Const MOVE_FOLDER    = "D:\MOVED\"

' �G���R�[�h�����f�[�^���o�͂���t�H���_(�Ō�̕�����"\")
Const OUTPUT_FOLDER  = "D:\ENCODED\"

' �v���t�@�C���ԍ�(���j���[�̈�ԏオ0)
Const OUTPUT_PROFILE = 0

' �o�̓v���O�C���ԍ�(���j���[�̈�ԏオ0)
Const OUTPUT_PLUGIN  = 0

' �o�̓t�@�C���̊g���q
Const OUTPUT_EXT     = ".wmv"

' AviUtl�̃t���p�X
Const AVIUTL_PATH    = "C:\Program Files\aviutl\aviutl.exe"

' AviUtl Control��u���Ă���t�H���_(�Ō�̕�����"\")
Const AUC_FOLDER     = ".\" ' = �X�N���v�g�Ɠ����t�H���_

Dim WHSHell, Fs
Set WSHShell = WScript.CreateObject("WScript.Shell")
Set Fs = CreateObject("Scripting.FileSystemObject")

Function Auc(command, arg)
  Auc = WSHShell.Run("""" & AUC_FOLDER & "auc_" & command & ".exe"" " & arg, 2, True)
End Function

Dim srcFiles, srcFile, date, input, output, i, hwnd, open

' AviUtl�̃E�B���h�E�ԍ����擾

hwnd = Auc("findwnd", "")
open = 0
If hwnd = 0 Then
  hwnd = Auc("exec", """" & AVIUTL_PATH & """")
  If hwnd = 0 Then
    Call WScript.Quit(-1)
  End if
  open = 1
End if

' �L���v�`�������t�@�C��������t�H���_����ɂȂ�܂ŌJ��Ԃ�
While Fs.GetFolder(SOURCE_FOLDER).Files.Count > 0

  ' SOURCE_FOLDER �ň�ԌÂ��t�@�C����T��
  Set srcFiles = Fs.GetFolder(SOURCE_FOLDER).Files
  i = 0
  For Each srcFile In srcFiles
    If i = 0 Then
      date   = srcFile.DateLastModified
      input  = srcFile.Path
      output = OUTPUT_FOLDER & Fs.GetBaseName(input) & OUTPUT_EXT
      i = 1
    Elseif date < oFile.DateLastModified then
      date   = srcFile.DateLastModified
      input  = srcFile.Path
      output = OUTPUT_FOLDER & Fs.GetBaseName(input) & OUTPUT_EXT
    End if
  Next
  
  ' �L���v�`�������t�@�C�����J��
  Call Auc("open",    CStr(hwnd) & " """ & input & """")
  Call WScript.Sleep(3000)
  
  ' �v���t�@�C����ݒ肷��
  Call Auc("setprof", CStr(hwnd) & " " & CStr(OUTPUT_PROFILE))
  Call WScript.Sleep(1000)
  
  ' �o�̓v���O�C������o�͂���
  Call Auc("plugout", CStr(hwnd) & " " & CStr(OUTPUT_PLUGIN) & " """ & output & """")
  
  ' �o�͂��I���܂ő҂�
  Call Auc("wait",    CStr(hwnd))
  
  ' �t�@�C�������
  Call Auc("close",   CStr(hwnd))
  Call WScript.Sleep(3000)
  
  ' �G���R�[�h���I������t�@�C�����ړ�����
  Call Fs.MoveFile(input, MOVE_FOLDER)

Wend

' �X�N���v�g�ŋN������AviUtl���I������
If open = 1 Then
  Call Auc("exit", CStr(hwnd))
End if

