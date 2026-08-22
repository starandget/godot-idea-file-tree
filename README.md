# IDEA File Tree for Godot

一个面向 Godot 4.7 的轻量编辑器插件。它提供更紧凑、接近 JetBrains IDEA
的 `res://` 文件树：清晰的层级连接线、紧凑行距和 Godot 原生资源图标。

插件不会修改项目资源，也不会替换 Godot 内置 FileSystem Dock。它会增加一个
独立的 **Project** Dock；不需要时可以随时禁用。

## 功能

- 紧凑的文件与文件夹排列
- 清晰的树形层级连接线
- 文件夹优先、按名称排序
- 双击打开场景和资源
- 文件变化后自动刷新
- 折叠父文件夹时同步折叠所有子文件夹

## 安装

1. 下载本仓库（GitHub 页面点击 **Code > Download ZIP**）。
2. 解压下载的文件。
3. 把解压目录中的 `addons/idea_file_tree` 整个复制到你的 Godot 项目中。
   最终应存在：`你的项目/addons/idea_file_tree/plugin.cfg`。
4. 用 Godot 打开你的项目。
5. 进入 **项目 > 项目设置 > 插件**。
6. 启用 **IDEA File Tree**。
7. 左侧会出现新的 **Project** Dock。原生 FileSystem Dock 可自行收起。

## 开发与预览

把本仓库根目录作为 Godot 项目导入并打开即可。仓库中的 `project.godot`
已经默认启用插件。

## 卸载

先在 **项目 > 项目设置 > 插件** 中禁用插件，然后删除
`addons/idea_file_tree` 文件夹。

## License

[MIT](LICENSE)

