# -*- coding: utf-8 -*-
import os
import sys
import codecs
import locale
import subprocess
import time
import shutil
import traceback
import random
''' AviUtlエンコード＆ファイル移動 '''

# あるディレクトリの中のサブディレクトリ下も含めたすべてのファイルについて、
# プロファイル＆出力プラグイン指定でエンコードし、
# エンコードが終わったら指定のディレクトリに移動する

#################################################
# 設定
# パスの区切り文字は円マーク（バックスラッシュ）ではなく
# スラッシュを使う
# （raw文字列でも\uに反応しちゃうから）
##################################################

#カレントディレクトリの取得
path = os.getcwd()
CURRENT_DIR = path.replace(os.path.sep, '/')
CURRENT_DIR = path.replace('//', '/')
# キャプチャしたファイルがあるディレクトリ
INPUT_DIR = CURRENT_DIR + r'/INPUT'

# エンコードが終わったファイルを移すディレクトリ
COMPLETED_DIR = CURRENT_DIR + r'/COMPLETED'

# エンコードしたデータを出力するディレクトリ
OUTPUT_DIR = CURRENT_DIR + r'/ENCODED'

# プロファイル番号(メニューの一番上が0)
OUTPUT_PROFILE = 0

# 出力プラグイン番号(メニューの一番上が0)
OUTPUT_PLUGIN = 1

# 入力ファイルの拡張子
INPUT_EXTENSIONS = ['.avi','.mp4']

# 出力ファイルの拡張子
OUTPUT_EXTENSION = '.mp4'

# AviUtlのフルパス
AVIUTL_PATH = CURRENT_DIR + r'/aviutl100/aviutl.exe'

# AviUtl Controlのフルパス
AUC_DIR = CURRENT_DIR + r'/auc'


#################################################
# 自動エンコード処理開始
#################################################

# デリミタ（/）を末尾に追加
addDelimiter = lambda s: s if s.endswith('/') else s + '/'

INPUT_DIR = addDelimiter(INPUT_DIR)
COMPLETED_DIR = addDelimiter(COMPLETED_DIR)
OUTPUT_DIR = addDelimiter(OUTPUT_DIR)

print('以下のパラメータが与えられました:')
print('INPUT_DIR = %s' % INPUT_DIR)
print('COMPLETED_DIR = %s' % COMPLETED_DIR)
print('OUTPUT_DIR = %s' % OUTPUT_DIR)
print('OUTPUT_PROFILE = %s' % OUTPUT_PROFILE)
print('OUTPUT_PLUGIN = %s' % OUTPUT_PLUGIN)
print('INPUT_EXTENSIONS = %s' % INPUT_EXTENSIONS)
print('OUTPUT_EXTENSION = %s' % OUTPUT_EXTENSION)
print('AVIUTL_PATH = %s' % AVIUTL_PATH)
print('AUC_DIR = %s' % AUC_DIR)
print()

#enc = lambda u: u.encode(locale.getpreferredencoding())
#dec = lambda s: s.decode(locale.getpreferredencoding())
quote = lambda s: '"%s"' % s
replace = lambda s: s.replace('/', '\\')

def run(command):
	p = subprocess.Popen(command, stdout = subprocess.PIPE)
	output = p.stdout.read()
	p.wait()
	return output.strip()
#run = lambda command: subprocess.call(command, shell = True)
class AUC(object):
	def __init__(self):
		self._isAutoLaunch = False
		self._hwnd = self.findwnd()
		if self._hwnd == 0:
			self._hwnd = self.launch(AVIUTL_PATH)
			self._isAutoLaunch = (self._hwnd != 0)
	@staticmethod
	def _auc(command, *args):
		args = ' '.join(map(str, args))
		command = 'auc_%s.exe %s' % (command, args)
		print('Run: ' + command)
		#return dec(run(enc(command)))
		return run(command)
	def isAutoLaunch(self):
		return self._isAutoLaunch
	def exists(self):
		return self._hwnd != 0 and self._hwnd == self.findwnd()
	def launch(self, path):
		return int(self._auc('exec', quote(path)))
	def findwnd(self):
		return int(self._auc('findwnd'))
	def exit(self):
		self._auc('exit', self._hwnd)
		self._hwnd = 0
		self._isAutoLaunch = False
	def open(self, file):
		self._auc('open', self._hwnd, quote(replace(file)))
	def openadd(self, file):
		self._auc('openadd', self._hwnd, quote(replace(file)))
	def audioadd(self, file):
		self._auc('audioadd', self._hwnd, quote(replace(file)))
	def close(self):
		self._auc('close', self._hwnd)
	def setprof(self, profile):
		self._auc('setprof', self._hwnd, profile)
	def aviout(self, file):
		self._auc('aviout', self._hwnd, quote(replace(file)))
	def wavout(self, file):
		self._auc('wavout', self._hwnd, quote(replace(file)))
	def plugout(self, plugin, file):
		self._auc('plugout', self._hwnd, plugin, quote(replace(file)))
	def plugbatch(self, plugin, file):
		self._auc('plugbatch', self._hwnd, plugin, quote(replace(file)))
	def wait(self):
		self._auc('wait', self._hwnd)

def getFiles(dir):
	files = []
	for file in os.listdir(dir):
		path = dir + file
		if os.path.isfile(path):
			if os.path.splitext(path)[1] in INPUT_EXTENSIONS:
				files.append(path)
		else:
			files += getFiles(addDelimiter(path))
	return files

def getSubDir(path):
	dir = addDelimiter(os.path.split(path)[0])
	if dir.startswith(INPUT_DIR):
		return dir[len(INPUT_DIR):]
	else:
		return ''

#def uploadVideo(args):



try:
	os.chdir(AUC_DIR) # カレントディレクトリをAviUtl Controlのある場所へ変更

	files = getFiles(INPUT_DIR)
	files.sort()
	if len(files) == 0:
		print('処理すべきファイルが見つかりませんでした')
		input('Press Enter Key...')
		exit()

	auc = AUC()
	getmtime = os.path.getmtime

	print('次のファイルを取得しました:')
	for file in files: print('-> ' + file)
	print()

	while auc.exists() and len(files) > 0:
		# 一番古いファイルから処理する
		inputFile = None
		mtime = 0
		for file in files:
			if inputFile == None or mtime > getmtime(file):
				inputFile = file
				mtime = getmtime(file)
		files.remove(inputFile)

		# サブディレクトリ取得とか出力先ディレクトリ設定とか
		basename = os.path.basename(inputFile)
		subDir = getSubDir(inputFile)
		completedDir = COMPLETED_DIR + subDir if COMPLETED_DIR != None else ''
		completedFile = completedDir + basename if COMPLETED_DIR != None else ''
		outputDir = OUTPUT_DIR + subDir
		outputFile = outputDir + os.path.splitext(basename)[0] + OUTPUT_EXTENSION

		print('次の設定でエンコードを開始します:')
		print('入力ファイル: %s' % inputFile)
		print('出力ファイル: %s' % outputFile)
		print('エンコード後ファイル: %s' % completedFile)
		print()

		# ファイルオープン、プロファイルの設定
		if not auc.exists(): break
		auc.open(inputFile)
		print('ファイルをオープンしました')
		if not auc.exists(): break
		auc.setprof(OUTPUT_PROFILE)
		time.sleep(1.000)
		print('プロファイルを設定しました')

		# 出力先ディレクトリがなければ作成
		if not os.path.exists(outputDir):
			os.makedirs(outputDir)
			print('出力先ディレクトリを作成しました')

		# 出力プラグインによる出力
		if not auc.exists(): break
		auc.plugout(OUTPUT_PLUGIN, outputFile)
		print('エンコード中です...')
		if not auc.exists(): break
		auc.wait()

		# ファイルクローズ
		if not os.path.exists(outputFile):
			break
		print('エンコードが完了しました')

		# ファイルクローズ
		if not auc.exists(): break
		auc.close()
		print('ファイルをクローズしました')
		time.sleep(3.000)

		# エンコードが終わったファイルを移動する
		# 移動先ディレクトリがなければ作成
		if COMPLETED_DIR != None:
			if not os.path.exists(completedDir):
				os.makedirs(completedDir)
				print('移動先ディレクトリを作成しました')
			if not auc.exists(): break
			shutil.move(inputFile, completedFile)
			print('エンコードが終了したファイルを移動しました')
		print()
        
	if auc.isAutoLaunch() and auc.exists():
		auc.exit()

except:
	traceback.print_exc()