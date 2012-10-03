--crown��morph�����ļ������ű�
global CrownExport		-- ����
global errString = stringstream""	-- ��������
global gMesh			-- ����mesh
global gMorpher		-- morpher
global channelList = #()		-- �����ݵ�channel
global meshString = stringstream""	-- �ļ��ִ�
global errString = stringstream""	-- ��������
global savePath = ""	-- �����Ŀ¼
global morphFileName = ""		-- morph mesh��
global textureFileName = ""		-- ��ͼ��
global animationNames = #()		-- ���ж���������
global animationTimePairs = #()	-- ���ж����Ŀ�ʼ�ͽ���ʱ��

-- ȥ���ַ���ͷβ�Ŀո�
function filterSpace instring =
(
	outstring = instring 
	while (outstring[1] == " ") do
	(
		outstring = substring outstring 2 -1
	)
	while (outstring[outstring.count] == " ") do
	(
		outstring = substring outstring 1 (outstring.count-1)
	)
	return outstring
)
-- ת��Сд
function lowercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring = copy instring
	for i=1 to outstring.count do
	(
		j = findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
	)
	return outstring
)
-- ���ý�����
function progress pro =
(
	CrownExport.progExport.value = pro	-- ������
)
-- ����Mesh����ͼ
function TextureExport edmesh =
(
	-- ������ͼ
	srcAllFileName = edmesh.material.diffuseMap.filename
	srcFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName

	--desFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName 
	--desFileName = getFilenameFile srcAllFileName + ".tga"	-- ��ͼ��Ϊtga
	desFileName = getFilenameFile srcAllFileName + ".dds"	-- ��ͼ��Ϊdds

	desAllFileName = savePath + desFileName
	desAllFileName = lowercase desAllFileName		-- Сд
	-- �����ͼ������
	justFileName = getFilenameFile desFileName
	justExtName = getFilenameType desFileName

	format "����ģ�� % ����ͼ %\n" edmesh.name desAllFileName 
	
	-- ���Դ��ͼ�Ƿ����
	isExist = false
	if( doesFileExist srcAllFileName ) then isExist = true

	testFileName = sysInfo.currentdir + "\\" + srcFileName;
	if( doesFileExist testFileName ) then isExist = true

	testFileName = maxFilePath + srcFileName;
	if( doesFileExist testFileName ) then isExist = true
 
	if(isExist == false) then
	(
		format "��ͼ % ������\n" srcAllFileName
		format "��ͼ % ������\n" srcAllFileName to: errString
		return undefined
	)

	srcBmp = edmesh.material.diffuseMap.bitmap
	desBmp = bitmap srcBmp.width srcBmp.height filename:desAllFileName 
		
	copy srcBmp desBmp
	save desBmp
	close desBmp
	
	format "������ͼ % ����\n" desAllFileName	
	return desAllFileName
)

-- ��鵼���Ϸ���
function checkMesh =
(
	-- ����ǰ���
	if gMesh == undefined then
	(
		format "��ѡ��Ҫ����������\n" to:errString 
		return false
	)
	if (classof gMesh)!=editable_mesh then
	(
		format "ѡ�������%����editable_mesh\n" gMesh.name to:errString
		return false
	)
	-- ���ҽ���һ��morpher
	mods = gMesh.modifiers
	if mods.count != 1 then 
	(
		format "������%����ֻ��һ��modifier,��ΪMorpher\n" gMesh.name to:errString
		return false
	)
	gMorpher = mods[1]	
	if (classof gMorpher as string != "Morpher") do
	(
		format "������%û��morpher\n" gMesh.name to:errString
		return false
	)
	
	WM3_RebuildInternalCache gMorpher
	
	-- �������Щchannel
	channelList.count = 0
	for ci=1 to 100 do
	(
		WM3_MC_Rebuild gMorpher ci
		if WM3_MC_HasData gMorpher ci then
		(
			append channelList ci
		)		
	)
	-- ���ÿ��channel
	vertexCount = gMesh.numverts
	format "������=%\n" vertexCount
	for ci=1 to channelList.count do
	(
		vc = WM3_MC_NumPts gMorpher channelList[ci]
		format "channel % %\n" channelList[ci] vc
		if vertexCount != vc then
		(
			format "���㲻ƥ��\n" to:errString
			return false
		)
	)
	-- �����ͼ
	if( (classof gMesh.material) as string != "Standardmaterial" ) then
	(
		format "% �Ĳ��ʲ���Standardmateria\n" gMesh.name to:errString
		return false
	)
		
	if( (classof gMesh.material.diffuseMap) as string != "Bitmaptexture" ) then
	(
		format "% �Ĳ��ʵ�diffusemap����Bitmaptexture\n" gMesh.name to:errString
		return false
	)
	
	textureFileName = gMesh.material.diffuseMap.filename
	format "������ͼΪ%\n" textureFileName 

	-- ��鶯��
	animationNames = #()
	animationTimePairs = #()
	
	modPanel.setCurrentObject gMorpher
	tagsNum = FrameTagManager.GetTagCount()		-- ����timetag����
	if tagsNum == 0 then 
	(
		format "û������Time Tag\n" to:errString
		return false
	)
	
	tagsPairNum = tagsNum / 2
	for pi = 1 to tagsPairNum do
	(
		tagId = FrameTagManager.GetTagID (pi*2-1)
		tagId2 = FrameTagManager.GetTagID (pi*2)
		tagName = FrameTagManager.GetNameByID tagId
		tagTime = FrameTagManager.GetTimeByID tagId
		tagTime2 = FrameTagManager.GetTimeByID tagId2

		tagTimeStr = tagTime as string
		tagTime2Str = tagTime2 as string
		t1 = (substring tagTimeStr 1 (tagTimeStr.count-1)) as number
		t2 = (substring tagTime2Str 1 (tagTime2Str.count-1)) as number
		tagName = filterSpace tagName 
		format "����(%) [%, %]\n" tagName t1 t2
		
		append animationNames tagName
		append animationTimePairs t1
		append animationTimePairs t2
	)
	
	progress 20
	
	return true
)

function exportHeader = 
(
	format "blfversion 1\n" to:meshString
	format "\n" to:meshString
	format "tex \"%\"\n" (getFilenameFile textureFileName) to:meshString
	format "\n" to:meshString
	-- ������ͼ
	TextureExport gMesh	
)

struct blVertexData
(
	vertex,
	uv,
	vertexIndex		-- �ö�����mesh�е�����
)

blVertices = #()	-- ��������
blIndices = #()	-- ��������

function exportMesh =
(
	-- ѡ��modifier�е�Editable Mesh,�Ե���ԭʼģ��
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject gMesh
	
	vertexNum = getNumVerts gMesh
	faceNum = getNumFaces gMesh
	
	blVertices = #()
	blIndices = #()
	
	-- ����	
	for fi=1 to faceNum do
	(
		vertindices = getFace gMesh fi		-- ��������
		tvertindices = meshop.getmapface gMesh 1 fi --uv����
		-- ����������������
		for fvi=1 to 3 do
		(
			vert = getVert gMesh vertindices[fvi]
			uv = meshop.getmapvert gMesh 1 tvertindices[fvi]
			
			--format "face=% vi=% verti=% vert=% uvi=% uv=%\n" \
			--	fi fvi vertindices[fvi] vert tvertindices[fvi] uv
			
			blIndex = 0
			for blVi=1 to blVertices.count do
			(
				if (blVertices[blVi].vertex == vert and blVertices[blVi].uv == uv) do
				(
					blIndex = blVi
					exit
				)
			)
									
			if blIndex == 0 then
			(	-- �����������޴˶���
				newblVert =  blVertexData()
				
				newblVert.vertex = vert
				newblVert.uv = uv
				newblVert	.vertexIndex = vertindices[fvi] as integer
								
				append blVertices newblVert
				blIndex = blVertices.count	
			)
			else
			(	-- �����������д˶�����
			
			)
			append blIndices (blIndex-1)
		)		
	)
	
	-- �����������������
	format "vertexNum %\n" blVertices.count to:meshString
	format "faceNum %\n" faceNum to:meshString
	format "indexNum %\n" blIndices.count to:meshString
	format "channelNum %\n" channelList.count to:meshString
	format "animationNum %\n" animationNames.count to:meshString
	format "\n" to:meshString
	
	format "vertices {\n" to:meshString
	for vi=1 to blVertices.count do
	(
		format "\tv % {\n" (vi-1) to:meshString
		-- ����λ��
		format "\t\t% % %\n" \
			blVertices[vi].vertex[1] blVertices[vi].vertex[3] blVertices[vi].vertex[2] to:meshString-- λ��
		-- uv
		format "\t\t% %\n" blVertices[vi].uv[1] (1-blVertices[vi].uv[2]) to:meshString
				
		format "\t}\n" to:meshString
	)
	format "}\n" to:meshString
	
	format "indices {\n" to:meshString
	for fi=1 to faceNum  do
	(	-- ����
		format "\t% % %\n" blIndices[fi*3] blIndices[fi*3-1] blIndices[fi*3-2] to:meshString
	)
	format "}\n" to:meshString
	
	progress 40

)

function exportMorph =
(
	if true do
	(
		-- ��ʾԭmesh�Ķ���
		format "mesh:\n"
		for vi=1 to gMesh.numverts do
		(
			v = getvert gMesh vi
			--format "p % = %\n" vi v
		)
		format "mesh:\n"
		for vi=1 to blVertices.count do
		(
			v = getvert gMesh blVertices[vi].vertexIndex
			--format "p% % = %\n" vi blVertices[vi].vertexIndex v
		)
		-- ����ÿ��channel�Ķ�������
		for ci=1 to channelList.count do
		(
			vertexCount = WM3_MC_NumMPts gMorpher channelList[ci]
			format "channel %:\n" channelList[ci]
			for vi=1 to blVertices.count do
			(
				point = WM3_MC_GetMorphPoint gMorpher channelList[ci] (blVertices[vi].vertexIndex-1)
				--format "p% % = %\n" vi blVertices[vi].vertexIndex point
			)			
		)
	)
	
	-- ����ÿ��channel�Ķ�������
	for ci=1 to channelList.count do
	(
		vertexCount = WM3_MC_NumMPts gMorpher channelList[ci]
		format "channel % {\n" ci to:meshString
		for vi=1 to blVertices.count do
		(
			point = WM3_MC_GetMorphPoint gMorpher channelList[ci] (blVertices[vi].vertexIndex-1)
	
			format "\tv % {\n" (vi-1) to:meshString
				format "\t\t% % %\n" point[1] point[3] point[2] to:meshString
				format "\t}\n" to:meshString
		)
		format "}\n" to:meshString
		
		progress (40 + 30*ci/channelList.count)
	)

)

function exportAnimation =
(
	modPanel.setCurrentObject gMorpher

	for pi = 1 to animationNames.count do
	(
		aniName = animationNames[pi]
		t1 = animationTimePairs[pi*2-1]
		t2 = animationTimePairs[pi*2]

		format "��������(%) [%, %]\n" aniName t1 t2
		
		keyFrame = t1 	-- start time
		lastKeyFrame = keyFrame 
		isEnd = false
		maxKey = 0
		
		-- ���Ҫ�Ķ���ʹ�����ļ���channel
		usedChannelList = #()
		do
		(
			set time keyFrame
			for ci=1 to channelList.count do
			(
				val = WM3_MC_GetValue gMorpher channelList[ci]
				if val > 0 then
				(
					if (findItem usedChannelList ci) == 0 then
						append usedChannelList ci
				)
			)
			
			-- ��һ�ؼ�֡
			lastKeyFrame = keyFrame
			nextKeyTimeStr = trackbar.getNextKeyTime()
			if nextKeyTimeStr == undefined then
			(
				keyFrame = t2+1
			)
			else
			(
				keyFrameStr = (nextKeyTimeStr as string)
				keyFrameStr = substring keyFrameStr 1 (keyFrameStr.count-1)	-- ȥ��f
				keyFrame = keyFrameStr as number
			)
			
			if isEnd == false and keyFrame >= t2 then
			(				
				keyFrame = t2
				isEnd = true;
			)
			
			maxKey += 1
		)
		while (keyFrame <= t2 and keyFrame >= lastKeyFrame and maxKey < 100)	-- maxKey���ؼ�֡
		
		-- ��ʾʹ�õ�channel
		for ui = 1 to usedChannelList.count do
		(
			format "ʹ�õ�channel: %\n" usedChannelList
		)
		if usedChannelList.count > 3 then
			format "����%ʹ�õ�channel������3\n" aniName to:errString
		
			
		keyFrame = t1 	-- start time
		lastKeyFrame = keyFrame 
		isEnd = false
		

		format "animation \"%\" {\n" aniName to:meshString
		-- ����ʹ�����ļ���channel
		format "\t% %\n" usedChannelList.count maxKey to:meshString
		format "\t" to:meshString
		for ui = 1 to usedChannelList.count do
		(
			format "% " usedChannelList[ui] to:meshString
		)
		format "\n" to:meshString

		maxKey = 0
		do
		(
			set time keyFrame
			format "\t%" keyFrame to:meshString
			
			for ci=1 to usedChannelList.count do
			(
				weight = WM3_MC_GetValue gMorpher channelList[usedChannelList[ci]]
				if weight < 0 then weight = 0.0
				if weight > 100 then weight = 100.0
				format " %" weight to:meshString
			)
			format "\n" to:meshString
			
			
			-- ��һ�ؼ�֡
			lastKeyFrame = keyFrame
			nextKeyTimeStr = trackbar.getNextKeyTime()
			if nextKeyTimeStr == undefined then
			(
				keyFrame = t2+1
			)
			else
			(
				keyFrameStr = (nextKeyTimeStr as string)
				keyFrameStr = substring keyFrameStr 1 (keyFrameStr.count-1)	-- ȥ��f
				keyFrame = keyFrameStr as number
			)
			
			if isEnd == false and keyFrame >= t2 then
			(				
				keyFrame = t2
				isEnd = true;
			)
			
			maxKey += 1
		)
		while (keyFrame <= t2 and keyFrame >= lastKeyFrame and maxKey < 100)	-- maxKey���ؼ�֡
		format "}\n" to:meshString
		
		progress (70 + 30*pi/animationNames.count)
	)
)
-- �������
function main =
(
	-- ָ�������ļ�
	if (CrownExport.fileNameEditor.text.count > 0) then
	(
		morphFileName = CrownExport.fileNameEditor.text
	)
	else
	(
		morphFileName = "test.blf"		
	)
	
	morphFileName=getsavefilename caption:"����Morph�����ļ�" \
			filename:morphFileName\
			types:"blf(*.blf)|*.blf"
	if morphFileName == undefined then return undefined
	
	CrownExport.fileNameEditor.text = morphFileName 
	--morphFileName = "C:\JerryO\3D\morph1\plane.blf"
	savePath = getFilenamePath morphFileName
	morphFile = createfile morphFileName 
	
	meshString = stringstream""
	errString = stringstream""
	
	try
	(
		gMesh = $
		if checkMesh() do
		(
			gMesh.position = [0,0,0]
			gMesh.rotation.x = 0
			gMesh.rotation.y = 0
			gMesh.rotation.z = 0
			gMesh.rotation.w = 1
			
			format "��ʼ���� %\n" gMesh
			exportHeader()		-- �ļ�ͷ
			exportMesh()			-- ����ԭʼmesh����
			exportMorph()			-- ����channel����
			exportAnimation()		-- ��������
			
			format "%" (meshString as string) to:morphFile
		)
	)
	catch
	(
		exceptionString = stringstream""
		format "����ʱ��������!\n*** % ***\n" (getCurrentException()) to:exceptionString
		messageBox (exceptionString as string) title:"����!"
	)
	close morphFile
	format "�رն����ļ�\n"
	
	-- ת������tagΪblt
	--thisMaxScriptDir = getSourceFileName()
	--thisMaxScriptDir = getFilenamePath thisMaxScriptDir 
	--commandStr = thisMaxScriptDir + "ConvertTgaToBlt.exe " + (getFilenamePath morphFileName)
	--format "DOS:%\n" commandStr 			
	--DOSCommand commandStr 
	-- ���󱨸�
	if ((errString as string).count > 0)  then
	(
		format "���󱨸�\n"
		format "%" (errString as string)
		messageBox (errString as string) title:"����!"
	)
)

rollout CrownExport "Crown Morph������������" width:160 height:160
(
	button bexport "    ����     "
	label lbl4 "�����ļ���" pos:[10,40] width:152 height:16
	edittext fileNameEditor "" pos:[2,55] width:150 height:16 
	progressbar progExport color:blue visible:false
	
	-- ����	
	on bexport pressed do
	( 
		progExport.visible = true
		progress 0
		main()
		progExport.visible = false
	)
)

-- �����Ի���
if CrownExportFloater != undefined do
(
	closerolloutfloater CrownExportFloater 
)
CrownExportFloater = newRolloutFloater "Morph����" 170 160 \
	(mouse.screenpos[1]-85) (mouse.screenpos[2]-60) -- ����һ��Rollout
addRollout CrownExport CrownExportFloater 

--main()