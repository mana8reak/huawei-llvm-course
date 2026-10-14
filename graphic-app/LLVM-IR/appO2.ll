; ModuleID = 'src/app.c'
source_filename = "src/app.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local void @drawCell(i32 noundef %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
  %4 = shl nsw i32 %0, 2
  %5 = shl nsw i32 %1, 2
  tail call void @simPutPixel(i32 noundef %4, i32 noundef %5, i32 noundef %2) #9
  %6 = or disjoint i32 %4, 1
  tail call void @simPutPixel(i32 noundef %6, i32 noundef %5, i32 noundef %2) #9
  %7 = or disjoint i32 %4, 2
  tail call void @simPutPixel(i32 noundef %7, i32 noundef %5, i32 noundef %2) #9
  %8 = or disjoint i32 %4, 3
  tail call void @simPutPixel(i32 noundef %8, i32 noundef %5, i32 noundef %2) #9
  %9 = or disjoint i32 %5, 1
  tail call void @simPutPixel(i32 noundef %4, i32 noundef %9, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %6, i32 noundef %9, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %7, i32 noundef %9, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %8, i32 noundef %9, i32 noundef %2) #9
  %10 = or disjoint i32 %5, 2
  tail call void @simPutPixel(i32 noundef %4, i32 noundef %10, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %6, i32 noundef %10, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %7, i32 noundef %10, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %8, i32 noundef %10, i32 noundef %2) #9
  %11 = or disjoint i32 %5, 3
  tail call void @simPutPixel(i32 noundef %4, i32 noundef %11, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %6, i32 noundef %11, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %7, i32 noundef %11, i32 noundef %2) #9
  tail call void @simPutPixel(i32 noundef %8, i32 noundef %11, i32 noundef %2) #9
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: write) uwtable
define dso_local void @createMap(ptr nocapture noundef writeonly %0) local_unnamed_addr #3 {
  %2 = getelementptr i32, ptr %0, i64 192
  br label %3

3:                                                ; preds = %14, %1
  %4 = phi i64 [ 0, %1 ], [ %15, %14 ]
  %5 = mul nuw nsw i64 %4, 384
  %6 = trunc i64 %4 to i32
  %7 = urem i32 %6, 25
  %8 = icmp ult i32 %7, 12
  %9 = getelementptr i32, ptr %2, i64 %5
  %10 = getelementptr inbounds i32, ptr %0, i64 %5
  store i32 1, ptr %10, align 4, !tbaa !5
  %11 = getelementptr i32, ptr %0, i64 %5
  %12 = getelementptr i32, ptr %0, i64 %5
  br label %17

13:                                               ; preds = %14
  ret void

14:                                               ; preds = %30
  %15 = add nuw nsw i64 %4, 1
  %16 = icmp eq i64 %15, 192
  br i1 %16, label %13, label %3, !llvm.loop !9

17:                                               ; preds = %3, %30
  %18 = phi i64 [ 1, %3 ], [ %31, %30 ]
  %19 = icmp eq i64 %18, 383
  br i1 %19, label %21, label %20

20:                                               ; preds = %17
  switch i64 %4, label %23 [
    i64 191, label %21
    i64 0, label %21
  ]

21:                                               ; preds = %20, %20, %17
  %22 = getelementptr i32, ptr %12, i64 %18
  store i32 1, ptr %22, align 4, !tbaa !5
  br label %30

23:                                               ; preds = %20
  %24 = icmp eq i64 %18, 192
  br i1 %24, label %25, label %28

25:                                               ; preds = %23
  br i1 %8, label %26, label %27

26:                                               ; preds = %25
  store i32 1, ptr %9, align 4, !tbaa !5
  br label %30

27:                                               ; preds = %25
  store i32 0, ptr %9, align 4, !tbaa !5
  br label %30

28:                                               ; preds = %23
  %29 = getelementptr i32, ptr %11, i64 %18
  store i32 0, ptr %29, align 4, !tbaa !5
  br label %30

30:                                               ; preds = %21, %26, %27, %28
  %31 = add i64 %18, 1
  %32 = icmp eq i64 %31, 384
  br i1 %32, label %14, label %17, !llvm.loop !11
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @calcWave(ptr nocapture noundef readonly %0, ptr nocapture noundef %1, ptr nocapture noundef readonly %2) local_unnamed_addr #4 {
  br label %4

4:                                                ; preds = %3, %8
  %5 = phi i64 [ 1, %3 ], [ %9, %8 ]
  %6 = mul nuw nsw i64 %5, 384
  br label %11

7:                                                ; preds = %8
  ret void

8:                                                ; preds = %36
  %9 = add nuw nsw i64 %5, 1
  %10 = icmp eq i64 %9, 191
  br i1 %10, label %7, label %4, !llvm.loop !13

11:                                               ; preds = %4, %36
  %12 = phi i64 [ 1, %4 ], [ %37, %36 ]
  %13 = add nuw nsw i64 %12, %6
  %14 = getelementptr inbounds i32, ptr %2, i64 %13
  %15 = load i32, ptr %14, align 4, !tbaa !5
  %16 = icmp eq i32 %15, 1
  br i1 %16, label %36, label %17

17:                                               ; preds = %11
  %18 = getelementptr i32, ptr %0, i64 %13
  %19 = getelementptr i32, ptr %18, i64 -384
  %20 = load i32, ptr %19, align 4, !tbaa !5
  %21 = getelementptr i32, ptr %18, i64 384
  %22 = load i32, ptr %21, align 4, !tbaa !5
  %23 = add nsw i32 %22, %20
  %24 = getelementptr i32, ptr %18, i64 -1
  %25 = load i32, ptr %24, align 4, !tbaa !5
  %26 = add nsw i32 %23, %25
  %27 = getelementptr i32, ptr %18, i64 1
  %28 = load i32, ptr %27, align 4, !tbaa !5
  %29 = add nsw i32 %26, %28
  %30 = sdiv i32 %29, 2
  %31 = getelementptr inbounds i32, ptr %1, i64 %13
  %32 = load i32, ptr %31, align 4, !tbaa !5
  %33 = sub nsw i32 %30, %32
  %34 = ashr i32 %33, 7
  %35 = sub nsw i32 %33, %34
  store i32 %35, ptr %31, align 4, !tbaa !5
  br label %36

36:                                               ; preds = %11, %17
  %37 = add nuw nsw i64 %12, 1
  %38 = icmp eq i64 %37, 383
  br i1 %38, label %8, label %11, !llvm.loop !14
}

; Function Attrs: nounwind uwtable
define dso_local void @drawField(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #0 {
  br label %3

3:                                                ; preds = %2, %9
  %4 = phi i64 [ 0, %2 ], [ %10, %9 ]
  %5 = mul nuw nsw i64 %4, 384
  %6 = trunc i64 %4 to i32
  %7 = trunc i64 %4 to i32
  br label %12

8:                                                ; preds = %9
  ret void

9:                                                ; preds = %41
  %10 = add nuw nsw i64 %4, 1
  %11 = icmp eq i64 %10, 192
  br i1 %11, label %8, label %3, !llvm.loop !15

12:                                               ; preds = %3, %41
  %13 = phi i64 [ 0, %3 ], [ %42, %41 ]
  %14 = add nuw nsw i64 %13, %5
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  %16 = load i32, ptr %15, align 4, !tbaa !5
  %17 = icmp eq i32 %16, 1
  br i1 %17, label %18, label %20

18:                                               ; preds = %12
  %19 = trunc i64 %13 to i32
  tail call void @drawCell(i32 noundef %19, i32 noundef %7, i32 noundef -8355712)
  br label %41

20:                                               ; preds = %12
  %21 = getelementptr inbounds i32, ptr %0, i64 %14
  %22 = load i32, ptr %21, align 4, !tbaa !5
  %23 = icmp slt i32 %22, 0
  %24 = sub nsw i32 0, %22
  %25 = tail call i32 @llvm.smin.i32(i32 %24, i32 255)
  %26 = icmp sgt i32 %22, 0
  %27 = ashr i32 %22, 2
  %28 = tail call i32 @llvm.smin.i32(i32 %27, i32 255)
  %29 = mul nsw i32 %22, %22
  %30 = lshr i32 %29, 5
  %31 = tail call i32 @llvm.umin.i32(i32 %30, i32 255)
  %32 = shl i32 %25, 16
  %33 = shl i32 %28, 8
  %34 = select i1 %26, i32 %31, i32 0
  %35 = or i32 %32, -16777216
  %36 = select i1 %23, i32 %35, i32 -16777216
  %37 = select i1 %26, i32 %33, i32 0
  %38 = or i32 %36, %37
  %39 = or disjoint i32 %38, %34
  %40 = trunc i64 %13 to i32
  tail call void @drawCell(i32 noundef %40, i32 noundef %6, i32 noundef %39)
  br label %41

41:                                               ; preds = %20, %18
  %42 = add nuw nsw i64 %13, 1
  %43 = icmp eq i64 %42, 384
  br i1 %43, label %9, label %12, !llvm.loop !16
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local void @addSplash(ptr nocapture noundef writeonly %0, ptr nocapture noundef readonly %1, i32 noundef %2) local_unnamed_addr #5 {
  %4 = lshr i32 %2, 16
  %5 = trunc i32 %4 to i16
  %6 = sdiv i16 %5, 4
  %7 = sext i16 %6 to i32
  %8 = lshr i32 %2, 2
  %9 = and i32 %8, 16383
  %10 = mul nuw nsw i32 %9, 384
  %11 = add nsw i32 %10, -384
  %12 = add nsw i32 %7, -1
  %13 = add nsw i32 %7, -2
  %14 = icmp ult i32 %13, 382
  %15 = add nsw i32 %9, -2
  %16 = icmp ult i32 %15, 190
  %17 = and i1 %14, %16
  br i1 %17, label %18, label %26

18:                                               ; preds = %3
  %19 = add nuw nsw i32 %12, %11
  %20 = zext nneg i32 %19 to i64
  %21 = getelementptr inbounds i32, ptr %1, i64 %20
  %22 = load i32, ptr %21, align 4, !tbaa !5
  %23 = icmp eq i32 %22, 1
  br i1 %23, label %26, label %24

24:                                               ; preds = %18
  %25 = getelementptr inbounds i32, ptr %0, i64 %20
  store i32 1500, ptr %25, align 4, !tbaa !5
  br label %26

26:                                               ; preds = %24, %18, %3
  %27 = icmp ult i32 %12, 382
  %28 = add nsw i32 %9, -2
  %29 = icmp ult i32 %28, 190
  %30 = and i1 %27, %29
  br i1 %30, label %31, label %39

31:                                               ; preds = %26
  %32 = add nuw nsw i32 %11, %7
  %33 = zext nneg i32 %32 to i64
  %34 = getelementptr inbounds i32, ptr %1, i64 %33
  %35 = load i32, ptr %34, align 4, !tbaa !5
  %36 = icmp eq i32 %35, 1
  br i1 %36, label %39, label %37

37:                                               ; preds = %31
  %38 = getelementptr inbounds i32, ptr %0, i64 %33
  store i32 1500, ptr %38, align 4, !tbaa !5
  br label %39

39:                                               ; preds = %37, %31, %26
  %40 = add nsw i32 %7, 1
  %41 = icmp ult i16 %6, 382
  %42 = add nsw i32 %9, -2
  %43 = icmp ult i32 %42, 190
  %44 = and i1 %41, %43
  br i1 %44, label %45, label %53

45:                                               ; preds = %39
  %46 = add nuw nsw i32 %40, %11
  %47 = zext nneg i32 %46 to i64
  %48 = getelementptr inbounds i32, ptr %1, i64 %47
  %49 = load i32, ptr %48, align 4, !tbaa !5
  %50 = icmp eq i32 %49, 1
  br i1 %50, label %53, label %51

51:                                               ; preds = %45
  %52 = getelementptr inbounds i32, ptr %0, i64 %47
  store i32 1500, ptr %52, align 4, !tbaa !5
  br label %53

53:                                               ; preds = %51, %45, %39
  %54 = mul nuw nsw i32 %9, 384
  %55 = add nsw i32 %9, -1
  %56 = icmp ult i32 %55, 190
  %57 = and i1 %14, %56
  br i1 %57, label %58, label %66

58:                                               ; preds = %53
  %59 = add nuw nsw i32 %12, %54
  %60 = zext nneg i32 %59 to i64
  %61 = getelementptr inbounds i32, ptr %1, i64 %60
  %62 = load i32, ptr %61, align 4, !tbaa !5
  %63 = icmp eq i32 %62, 1
  br i1 %63, label %66, label %64

64:                                               ; preds = %58
  %65 = getelementptr inbounds i32, ptr %0, i64 %60
  store i32 1500, ptr %65, align 4, !tbaa !5
  br label %66

66:                                               ; preds = %64, %58, %53
  %67 = add nsw i32 %9, -1
  %68 = icmp ult i32 %67, 190
  %69 = and i1 %27, %68
  br i1 %69, label %70, label %78

70:                                               ; preds = %66
  %71 = add nuw nsw i32 %54, %7
  %72 = zext nneg i32 %71 to i64
  %73 = getelementptr inbounds i32, ptr %1, i64 %72
  %74 = load i32, ptr %73, align 4, !tbaa !5
  %75 = icmp eq i32 %74, 1
  br i1 %75, label %78, label %76

76:                                               ; preds = %70
  %77 = getelementptr inbounds i32, ptr %0, i64 %72
  store i32 1500, ptr %77, align 4, !tbaa !5
  br label %78

78:                                               ; preds = %76, %70, %66
  %79 = add nsw i32 %9, -1
  %80 = icmp ult i32 %79, 190
  %81 = and i1 %41, %80
  br i1 %81, label %82, label %90

82:                                               ; preds = %78
  %83 = add nuw nsw i32 %40, %54
  %84 = zext nneg i32 %83 to i64
  %85 = getelementptr inbounds i32, ptr %1, i64 %84
  %86 = load i32, ptr %85, align 4, !tbaa !5
  %87 = icmp eq i32 %86, 1
  br i1 %87, label %90, label %88

88:                                               ; preds = %82
  %89 = getelementptr inbounds i32, ptr %0, i64 %84
  store i32 1500, ptr %89, align 4, !tbaa !5
  br label %90

90:                                               ; preds = %88, %82, %78
  %91 = icmp ult i32 %9, 190
  %92 = mul nuw nsw i32 %9, 384
  %93 = add nuw nsw i32 %92, 384
  %94 = and i1 %14, %91
  br i1 %94, label %95, label %103

95:                                               ; preds = %90
  %96 = add nuw nsw i32 %12, %93
  %97 = zext nneg i32 %96 to i64
  %98 = getelementptr inbounds i32, ptr %1, i64 %97
  %99 = load i32, ptr %98, align 4, !tbaa !5
  %100 = icmp eq i32 %99, 1
  br i1 %100, label %103, label %101

101:                                              ; preds = %95
  %102 = getelementptr inbounds i32, ptr %0, i64 %97
  store i32 1500, ptr %102, align 4, !tbaa !5
  br label %103

103:                                              ; preds = %101, %95, %90
  %104 = and i1 %27, %91
  br i1 %104, label %105, label %113

105:                                              ; preds = %103
  %106 = add nuw nsw i32 %93, %7
  %107 = zext nneg i32 %106 to i64
  %108 = getelementptr inbounds i32, ptr %1, i64 %107
  %109 = load i32, ptr %108, align 4, !tbaa !5
  %110 = icmp eq i32 %109, 1
  br i1 %110, label %113, label %111

111:                                              ; preds = %105
  %112 = getelementptr inbounds i32, ptr %0, i64 %107
  store i32 1500, ptr %112, align 4, !tbaa !5
  br label %113

113:                                              ; preds = %111, %105, %103
  %114 = and i1 %41, %91
  br i1 %114, label %115, label %123

115:                                              ; preds = %113
  %116 = add nuw nsw i32 %40, %93
  %117 = zext nneg i32 %116 to i64
  %118 = getelementptr inbounds i32, ptr %1, i64 %117
  %119 = load i32, ptr %118, align 4, !tbaa !5
  %120 = icmp eq i32 %119, 1
  br i1 %120, label %123, label %121

121:                                              ; preds = %115
  %122 = getelementptr inbounds i32, ptr %0, i64 %117
  store i32 1500, ptr %122, align 4, !tbaa !5
  br label %123

123:                                              ; preds = %121, %115, %113
  ret void
}

; Function Attrs: noreturn nounwind uwtable
define dso_local void @app() local_unnamed_addr #6 {
  %1 = alloca [73728 x i32], align 16
  %2 = alloca [73728 x i32], align 16
  %3 = alloca [73728 x i32], align 16
  call void @llvm.lifetime.start.p0(i64 294912, ptr nonnull %1) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(294912) %1, i8 0, i64 294912, i1 false)
  call void @llvm.lifetime.start.p0(i64 294912, ptr nonnull %2) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(294912) %2, i8 0, i64 294912, i1 false)
  call void @llvm.lifetime.start.p0(i64 294912, ptr nonnull %3) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(294912) %3, i8 0, i64 294912, i1 false)
  %4 = getelementptr inbounds i32, ptr %1, i64 192
  br label %5

5:                                                ; preds = %13, %0
  %6 = phi i64 [ 0, %0 ], [ %14, %13 ]
  %7 = mul nuw nsw i64 %6, 384
  %8 = trunc i64 %6 to i32
  %9 = urem i32 %8, 25
  %10 = icmp ult i32 %9, 12
  %11 = getelementptr i32, ptr %4, i64 %7
  %12 = getelementptr inbounds i32, ptr %1, i64 %7
  store i32 1, ptr %12, align 16, !tbaa !5
  br label %16

13:                                               ; preds = %29
  %14 = add nuw nsw i64 %6, 1
  %15 = icmp eq i64 %14, 192
  br i1 %15, label %32, label %5, !llvm.loop !9

16:                                               ; preds = %29, %5
  %17 = phi i64 [ 1, %5 ], [ %30, %29 ]
  %18 = icmp eq i64 %17, 383
  br i1 %18, label %20, label %19

19:                                               ; preds = %16
  switch i64 %6, label %22 [
    i64 191, label %20
    i64 0, label %20
  ]

20:                                               ; preds = %19, %19, %16
  %21 = getelementptr i32, ptr %12, i64 %17
  store i32 1, ptr %21, align 4, !tbaa !5
  br label %29

22:                                               ; preds = %19
  %23 = icmp eq i64 %17, 192
  br i1 %23, label %24, label %27

24:                                               ; preds = %22
  br i1 %10, label %25, label %26

25:                                               ; preds = %24
  store i32 1, ptr %11, align 16, !tbaa !5
  br label %29

26:                                               ; preds = %24
  store i32 0, ptr %11, align 16, !tbaa !5
  br label %29

27:                                               ; preds = %22
  %28 = getelementptr i32, ptr %12, i64 %17
  store i32 0, ptr %28, align 4, !tbaa !5
  br label %29

29:                                               ; preds = %27, %26, %25, %20
  %30 = add nuw nsw i64 %17, 1
  %31 = icmp eq i64 %30, 384
  br i1 %31, label %13, label %16, !llvm.loop !11

32:                                               ; preds = %13, %126
  %33 = phi ptr [ %34, %126 ], [ %3, %13 ]
  %34 = phi ptr [ %33, %126 ], [ %2, %13 ]
  br label %35

35:                                               ; preds = %39, %32
  %36 = phi i64 [ 0, %32 ], [ %40, %39 ]
  %37 = mul nuw nsw i64 %36, 384
  %38 = trunc i64 %36 to i32
  br label %42

39:                                               ; preds = %68
  %40 = add nuw nsw i64 %36, 1
  %41 = icmp eq i64 %40, 192
  br i1 %41, label %73, label %35, !llvm.loop !15

42:                                               ; preds = %68, %35
  %43 = phi i64 [ 0, %35 ], [ %71, %68 ]
  %44 = add nuw nsw i64 %43, %37
  %45 = getelementptr inbounds i32, ptr %1, i64 %44
  %46 = load i32, ptr %45, align 4, !tbaa !5
  %47 = icmp eq i32 %46, 1
  br i1 %47, label %68, label %48

48:                                               ; preds = %42
  %49 = getelementptr inbounds i32, ptr %34, i64 %44
  %50 = load i32, ptr %49, align 4, !tbaa !5
  %51 = icmp slt i32 %50, 0
  %52 = sub nsw i32 0, %50
  %53 = tail call i32 @llvm.smin.i32(i32 %52, i32 255)
  %54 = icmp sgt i32 %50, 0
  %55 = ashr i32 %50, 2
  %56 = tail call i32 @llvm.smin.i32(i32 %55, i32 255)
  %57 = mul nsw i32 %50, %50
  %58 = lshr i32 %57, 5
  %59 = tail call i32 @llvm.umin.i32(i32 %58, i32 255)
  %60 = shl i32 %53, 16
  %61 = shl i32 %56, 8
  %62 = select i1 %54, i32 %59, i32 0
  %63 = or i32 %60, -16777216
  %64 = select i1 %51, i32 %63, i32 -16777216
  %65 = select i1 %54, i32 %61, i32 0
  %66 = or i32 %64, %65
  %67 = or disjoint i32 %66, %62
  br label %68

68:                                               ; preds = %42, %48
  %69 = phi i32 [ %67, %48 ], [ -8355712, %42 ]
  %70 = trunc i64 %43 to i32
  tail call void @drawCell(i32 noundef %70, i32 noundef %38, i32 noundef %69)
  %71 = add nuw nsw i64 %43, 1
  %72 = icmp eq i64 %71, 384
  br i1 %72, label %39, label %42, !llvm.loop !16

73:                                               ; preds = %39
  tail call void (...) @simFlush() #9
  br label %74

74:                                               ; preds = %77, %73
  %75 = phi i64 [ 1, %73 ], [ %78, %77 ]
  %76 = mul nuw nsw i64 %75, 384
  br label %83

77:                                               ; preds = %108
  %78 = add nuw nsw i64 %75, 1
  %79 = icmp eq i64 %78, 191
  br i1 %79, label %80, label %74, !llvm.loop !13

80:                                               ; preds = %77
  %81 = tail call i32 (...) @simHasClick() #9
  %82 = icmp eq i32 %81, 0
  br i1 %82, label %115, label %111

83:                                               ; preds = %108, %74
  %84 = phi i64 [ 1, %74 ], [ %109, %108 ]
  %85 = add nuw nsw i64 %84, %76
  %86 = getelementptr inbounds i32, ptr %1, i64 %85
  %87 = load i32, ptr %86, align 4, !tbaa !5
  %88 = icmp eq i32 %87, 1
  br i1 %88, label %108, label %89

89:                                               ; preds = %83
  %90 = getelementptr i32, ptr %34, i64 %85
  %91 = getelementptr i32, ptr %90, i64 -384
  %92 = load i32, ptr %91, align 4, !tbaa !5
  %93 = getelementptr i32, ptr %90, i64 384
  %94 = load i32, ptr %93, align 4, !tbaa !5
  %95 = add nsw i32 %94, %92
  %96 = getelementptr i32, ptr %90, i64 -1
  %97 = load i32, ptr %96, align 4, !tbaa !5
  %98 = add nsw i32 %95, %97
  %99 = getelementptr i32, ptr %90, i64 1
  %100 = load i32, ptr %99, align 4, !tbaa !5
  %101 = add nsw i32 %98, %100
  %102 = sdiv i32 %101, 2
  %103 = getelementptr inbounds i32, ptr %33, i64 %85
  %104 = load i32, ptr %103, align 4, !tbaa !5
  %105 = sub nsw i32 %102, %104
  %106 = ashr i32 %105, 7
  %107 = sub nsw i32 %105, %106
  store i32 %107, ptr %103, align 4, !tbaa !5
  br label %108

108:                                              ; preds = %89, %83
  %109 = add nuw nsw i64 %84, 1
  %110 = icmp eq i64 %109, 383
  br i1 %110, label %77, label %83, !llvm.loop !14

111:                                              ; preds = %80, %111
  %112 = tail call i32 (...) @simGetClick() #9
  call void @addSplash(ptr noundef %33, ptr noundef nonnull %1, i32 noundef %112)
  %113 = tail call i32 (...) @simHasClick() #9
  %114 = icmp eq i32 %113, 0
  br i1 %114, label %115, label %111, !llvm.loop !17

115:                                              ; preds = %111, %80
  %116 = tail call i32 (...) @simRand() #9
  %117 = srem i32 %116, 100
  %118 = icmp eq i32 %117, 0
  br i1 %118, label %119, label %126

119:                                              ; preds = %115
  %120 = tail call i32 (...) @simRand() #9
  %121 = srem i32 %120, 1536
  %122 = shl nsw i32 %121, 16
  %123 = tail call i32 (...) @simRand() #9
  %124 = srem i32 %123, 768
  %125 = or i32 %122, %124
  call void @addSplash(ptr noundef %33, ptr noundef nonnull %1, i32 noundef %125)
  br label %126

126:                                              ; preds = %119, %115
  br label %32
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #7

declare void @simFlush(...) local_unnamed_addr #2

declare i32 @simHasClick(...) local_unnamed_addr #2

declare i32 @simGetClick(...) local_unnamed_addr #2

declare i32 @simRand(...) local_unnamed_addr #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #8

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umin.i32(i32, i32) #8

attributes #0 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree norecurse nosync nounwind memory(argmem: write) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { noreturn nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #8 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #9 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 18.1.8 (++20240731025043+3b5b5c1ec4a3-1~exp1~20240731145144.92)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = distinct !{!9, !10}
!10 = !{!"llvm.loop.mustprogress"}
!11 = distinct !{!11, !10, !12}
!12 = !{!"llvm.loop.peeled.count", i32 1}
!13 = distinct !{!13, !10}
!14 = distinct !{!14, !10}
!15 = distinct !{!15, !10}
!16 = distinct !{!16, !10}
!17 = distinct !{!17, !10}
