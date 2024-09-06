store user patches at location patches/user and those will be applied to vscode source git by the scripts


crash-reporter.patch
main.js 文件中的 configureCrashReporter() 函数中添加了一个 else 分支，并在其中添加了 return 语句。
这个更改的作用是，如果之前的条件不满足，则立即返回，终止函数的执行。这通常用于在特定条件下避免执行后续的代码逻辑。


patches/disable-cloud.patch
editSessionsStorageService.ts 文件中删除了与 registerSignInAction() 方法相关的代码。
这个方法负责注册 "Turn on Cloud Changes" 的操作，当用户未登录时，提供登录选项来开启云编辑会话同步。
这种更改通常是为了减少用户的干预，简化操作流程。如果这是你的预期目的，那么删除这个功能是合理的。如果还有其他地方需要补充处理登录逻辑，可以将相关功能转移到其他模块中。

patches/disable-signature-verification.patch
移除 isBoolean 检查并硬编码返回值：

    你删除了对 this.configurationService.getValue('extensions.verifySignature') 的值是否为布尔值的检查，并将其结果直接改为返回 false，即禁用了扩展签名验证。
@ts-expect-error 注释：

    你在 IConfigurationService 依赖注入前添加了 @ts-expect-error no-unused-variable 注释，目的是忽略 TypeScript 编译器的 "未使用变量" 警告。


patches/ext-from-gh.patch
builtInExtensions.js 和 builtInExtensions.ts 文件的更改，移除了从 extensionsGallery 中获取扩展下载链接的逻辑，现在只从 GitHub 下载扩展。
这一改动的主要影响是放弃了从官方市场 (Marketplace) 下载扩展，转而只通过 GitHub 获取。
在 /home/siwan/mycode/vscode-build-for-riscv/vscode/build/lib/fetch.js 文件的第 45 行，可以找到与请求超时相关的逻辑，尝试增加超时时间，例如将 Timeout 设置为更大的值：


patches/feat-announcements.patch
这个功能增强了欢迎页面的互动性，通过实时更新公告，用户可以看到更多来自官方的最新动态。


patches/fix-build-linux.patch
构建任务调整：确保 .deb 和 .rpm 包的准备工作与打包任务串联执行，避免任务之间的依赖问题。
依赖项检查调整：通过将 FAIL_BUILD_FOR_NEW_DEPENDENCIES 设置为 false，使构建过程中如果发现新依赖不会中断构建，提供更灵活的构建体验。
RPM 包更新：在 RPM 包中新增对 product.json 文件的保护，确保用户修改的配置文件不会在升级时被覆盖。


patches/fix-eol-banner.patch
这个补丁对 VSCode 中的 Banner 组件进行了改进，增加了“不再显示”（Never Show Again）功能，允许用户选择不再显示特定的横幅通知。


patches/merge-user-product.patch
引入 fileURLToPath： 在 main.js 中通过 url 模块的 fileURLToPath 函数解析用户产品配置文件路径。这将把 file:// URL 转换为实际的文件路径，以便后续操作。
resolveUserProduct 函数：

    新增了一个函数 resolveUserProduct，用于在应用启动时读取 product.json 文件的用户定制版本。
    该函数尝试读取用户的 product.json 文件，并将其赋值到 global 对象的 _VSCODE_USER_PRODUCT_JSON 上，供后续使用。
在 startup 函数中调用 resolveUserProduct：

    在应用启动时通过 resolveUserProduct 函数，将用户定制的 product.json 文件加载到全局变量中。
合并 product.json 数据：

    在 product.ts 文件中，合并全局的 _VSCODE_USER_PRODUCT_JSON 中的配置和现有的 product 对象。这种合并逻辑使用了一个递归函数 merge 来深度合并用户自定义的配置和默认配置。
    如果用户在 product.json 中自定义了 extensionsGallery 相关的 URL 配置，它们将覆盖默认的配置。



patches/ppc64le-and-riscv64-support.patch

增加了对riscv架构的支持，增加了编译人物，对于electron的设置
增加了对 Electron 仓库和标签的环境变量覆盖功能，特别是为不支持 RISC-V 和 PPC64LE 架构的 Electron 提供自定义仓库和标签的选项。具体的逻辑如下：
1.定义 electronOverride 对象：
const electronOverride = {};
创建一个空的 electronOverride 对象，用于存储覆盖的 Electron 仓库和标签信息。
2.通过环境变量 VSCODE_ELECTRON_REPO 覆盖 Electron 仓库：
if (process.env.VSCODE_ELECTRON_REPO) {
    electronOverride.repo = process.env.VSCODE_ELECTRON_REPO;
}
如果环境变量 VSCODE_ELECTRON_REPO 被设置，就将其值赋给 electronOverride.repo。
这意味着你可以通过该环境变量指定自定义的 Electron 仓库，用于替代默认的仓库地址。
3.通过环境变量 VSCODE_ELECTRON_TAG 覆盖 Electron 标签：
if (process.env.VSCODE_ELECTRON_TAG) {
    electronOverride.tag = process.env.VSCODE_ELECTRON_TAG;
}
如果环境变量 VSCODE_ELECTRON_TAG 被设置，就将其值赋给 electronOverride.tag。
这允许你通过环境变量指定特定的 Electron 版本标签，从而替换默认使用的版本。

在构建针对 riscv64 或 ppc64le 架构的 VSCode 时，可以通过设置以下环境变量来自定义 Electron 仓库和版本：
export VSCODE_ELECTRON_REPO="your-electron-repo"
export VSCODE_ELECTRON_TAG="your-electron-tag"

getDebPackageArch 和 getRpmPackageArch 函数：你为这两个函数添加了对 ppc64le 和 riscv64 的支持，以便生成正确的 Debian 和 RPM 包名。
getDebPackageArch: 现在返回 ppc64el 和 riscv64。
getRpmPackageArch: 现在返回 ppc64le 和 riscv64。
BUILD_TARGETS 增加了 ppc64le 和 riscv64：你将 ppc64le 和 riscv64 架构添加到 BUILD_TARGETS 列表中，以便这些架构可以被编译和打包。

riscv64 支持：
类似地，你为 riscv64 架构添加了 riscv64-linux-gnu 的路径，确保编译时能够找到 RISC-V 架构下的库。

riscv64 支持：
类似地，在 cmd.push 中为 riscv64 架构添加了 riscv64-linux-gnu 的库路径，包括：
  chromiumSysroot 的 usr/lib 和 lib 目录。
  vscodeSysroot 的 usr/lib 和 lib 目录。
  这些改动使得 ppc64el 和 riscv64 架构能够正确编译和链接相关的库，保证生成的可执行文件在这两个架构上运行时能够找到所有依赖。

riscv64 依赖

    包括了与 ppc64el 类似的库，如 libc6、libglib2.0-0 和 libstdc++6，同时也涵盖了 RISC-V 架构的特定库，如 libatomic1，确保架构依赖能够正常链接。
    libx11-6、libxkbcommon0 和 xdg-utils 等依赖用于支持图形化应用。

这些改动保证了在构建和打包时，针对 ppc64el 和 riscv64 架构的依赖库能被正确引用和安装，提升了跨架构支持的完整性。
