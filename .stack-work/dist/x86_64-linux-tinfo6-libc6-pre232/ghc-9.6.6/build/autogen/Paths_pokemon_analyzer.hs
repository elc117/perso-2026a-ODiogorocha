{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
#if __GLASGOW_HASKELL__ >= 810
{-# OPTIONS_GHC -Wno-prepositive-qualified-module #-}
#endif
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_pokemon_analyzer (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath




bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/workspaces/perso-2026a-ODiogorocha/pokemon_analyzer/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e481cb8b32c8d406e64f360f892315fe7d9ced0ccd616da93d5719e20643dc12/9.6.6/bin"
libdir     = "/workspaces/perso-2026a-ODiogorocha/pokemon_analyzer/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e481cb8b32c8d406e64f360f892315fe7d9ced0ccd616da93d5719e20643dc12/9.6.6/lib/x86_64-linux-ghc-9.6.6/pokemon-analyzer-0.1.0.0-8oaBGJpwiNaF1zLNEdDNHp"
dynlibdir  = "/workspaces/perso-2026a-ODiogorocha/pokemon_analyzer/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e481cb8b32c8d406e64f360f892315fe7d9ced0ccd616da93d5719e20643dc12/9.6.6/lib/x86_64-linux-ghc-9.6.6"
datadir    = "/workspaces/perso-2026a-ODiogorocha/pokemon_analyzer/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e481cb8b32c8d406e64f360f892315fe7d9ced0ccd616da93d5719e20643dc12/9.6.6/share/x86_64-linux-ghc-9.6.6/pokemon-analyzer-0.1.0.0"
libexecdir = "/workspaces/perso-2026a-ODiogorocha/pokemon_analyzer/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e481cb8b32c8d406e64f360f892315fe7d9ced0ccd616da93d5719e20643dc12/9.6.6/libexec/x86_64-linux-ghc-9.6.6/pokemon-analyzer-0.1.0.0"
sysconfdir = "/workspaces/perso-2026a-ODiogorocha/pokemon_analyzer/.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/e481cb8b32c8d406e64f360f892315fe7d9ced0ccd616da93d5719e20643dc12/9.6.6/etc"

getBinDir     = catchIO (getEnv "pokemon_analyzer_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "pokemon_analyzer_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "pokemon_analyzer_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "pokemon_analyzer_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "pokemon_analyzer_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "pokemon_analyzer_sysconfdir") (\_ -> return sysconfdir)



joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
