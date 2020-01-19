@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
chcp 65001
echo 开始监测python环境
::for /f "tokens=2" %%h in ('python --version ^| findstr /c:"3.6"') do set PYVER2=0
::python --version > temp.txt 2>&1
::type temp.txt | find "3.6"
python --version
if %errorlevel% == 0 (
  goto pythonCheck
) else (
  @echo 未找到python环境 即将退出安装
  goto out
)

:pythonCheck
python -c "import sys; print (sys.version)" | findstr 3.6
if %errorlevel% == 0 (
  @echo 当前python环境为3.6 将安装3.6版本的第三方库
  goto pipCheck
) else (
  @echo 当前环境不是3.6 即将退出安装
  goto out
)

:pipCheck
echo 开始监测pip
python -m pip list
if %errorlevel% == 0 (
  echo pip环境正常
  goto onetryWheel
) else (
  echo 您的环境中没有监测到可用的pip，建议您卸载当前python，去官网重新下载。
  goto out
)

:onetryWheel
echo 开始安装wheel
python -m pip install wheel
if %errorlevel% == 0 (
  echo wheel安装完毕
  goto onetrySdk
) else (
  echo 安装wheel失败，重试第二次
  goto twotryWheel
) 

:twotryWheel
echo 开始安装wheel
python -m pip install wheel
if %errorlevel% == 0 (
  echo wheel安装完毕
  goto onetrySdk
) else (
  echo 安装wheel失败，重试第三次
  goto threetryWheel
) 

:threetryWheel
echo 开始安装wheel
python -m pip install wheel
if %errorlevel% == 0 (
  echo wheel安装完毕
  goto onetrySdk
) else (
  goto failOut
) 

:onetrySdk
echo 开始安装sdk
python -m pip install nft-sdk
if %errorlevel% == 0 (
  echo sdk安装完毕
  goto ontryPandas
) else (
  echo 安装sdk失败，重试第二次
  goto twotrySdk
) 

:twotrySdk
echo 开始安装sdk
python -m pip install nft-sdk
if %errorlevel% == 0 (
  echo sdk安装完毕
  goto ontryPandas
) else (
  echo 安装sdk失败，重试第三次
  goto threetrySdk
) 

:threetrySdk
echo 开始安装sdk
python -m pip install nft-sdk
if %errorlevel% == 0 (
  echo sdk安装完毕
  goto ontryPandas
) else (
  goto failOut
) 

:ontryPandas
echo 开始安装pandas
python -m pip install pandas
if %errorlevel% == 0 (
  echo 已安装pandas
  goto installTalib
) else (
  echo 安装pandas失败，重试第二次
  goto twotryPandas
)

:twotryPandas
echo 开始安装pandas
python -m pip install pandas
if %errorlevel% == 0 (
  echo 已安装pandas
  goto installTalib
) else (
  echo 安装pandas失败，重试第三次
  goto threetryPandas
)

:threetryPandas
echo 开始安装pandas
python -m pip install pandas
if %errorlevel% == 0 (
  echo 已安装pandas
  goto installTalib
) else (
  goto failOut
)

:installTalib
echo 开始安装talib
@for /f "delims=" %%i in ('where python') do set pythonDir=%%i 
set pythonDirs=%pythonDir:~0,-11%
cd /d "%pythonDirs%\Lib\site-packages\third_lib\" 
python -m pip install ./TA_Lib-0.4.17-cp36-cp36m-win_amd64.whl
if %errorlevel% == 0 (
  echo 已安装talib
  echo python环境初始化完成 关闭当前控制台即可使用BiQuant ...
  echo "this" > batsuccess
  goto out
) else (
  echo 未找到合适版本的talib包，即将退出安装，请联系我们的工作人员帮您解决...
  goto out
) 

:failOut
echo 已经重试三次，请稍后重新安装
goto out

:out
pause
exit
