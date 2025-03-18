#--------------------------------------------------------------
# codesign.sh
# pre-condition: universal chugin built
#  are located in the proper directories 
#--------------------------------------------------------------

# where the .chug file can be found
CHUGIN_UB=./Hydra.chug

# codesign Line.chug
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements Chugin.entitlements --sign "Developer ID Application" ${CHUGIN_UB}
